// backend/src/services/websocket.service.js
import { Server } from 'ws';
import { v4 as uuidv4 } from 'uuid';
import { info, warn, error as _error } from '../utils/logger';
import { verifyToken } from '../utils/auth';
import { ChatSession } from '../models/chat-session.model';
import { User } from '../models/user.model';
import { ChatMessage } from '../models/chat-message.model';
import { AiService } from './ai.service';

class WebSocketService {
  constructor() {
    this.wss = null;
    this.activeConnections = new Map();
    this.chatSessions = new Map();
    this.ipConnections = new Map();
    this.aiService = new AiService();
  }

  initialize(server) {
    this.wss = new Server({ server });
    
    info('WebSocket server initialized');
    
    this.wss.on('connection', (ws, req) => {
      // Generate unique connection ID
      const connectionId = uuidv4();
      ws.connectionId = connectionId;
      
      // Get client IP
      const ip = req.headers['x-forwarded-for'] || 
                 req.connection.remoteAddress;
      ws.ip = ip;
      
      // Track IP connections for rate limiting
      const ipCount = this.ipConnections.get(ip) || 0;
      this.ipConnections.set(ip, ipCount + 1);
      
      // Check rate limiting
      if (this.ipConnections.get(ip) > 50) {
        warn(`Rate limit exceeded for IP: ${ip}`);
        ws.close(1008, 'Rate limit exceeded');
        return;
      }
      
      // Add to active connections
      this.activeConnections.set(connectionId, {
        ws,
        userId: null,
        authenticated: false,
        sessionId: null,
        lastActivity: Date.now(),
      });
      
      info(`New WebSocket connection: ${connectionId} from ${ip}`);
      
      // Set up event handlers
      ws.on('message', async (message) => {
        try {
          const data = JSON.parse(message);
          await this.handleMessage(ws, data);
        } catch (error) {
          _error('Error processing WebSocket message', error);
          this.sendError(ws, 'Error processing message');
        }
      });
      
      ws.on('close', (code, message) => {
        const connectionId = ws.connectionId;
        const ip = ws.ip;
        
        if (this.activeConnections.has(connectionId)) {
          const connection = this.activeConnections.get(connectionId);
          
          // Remove from session if in one
          if (connection.sessionId && this.chatSessions.has(connection.sessionId)) {
            this.leaveSession(connectionId, connection.sessionId);
          }
          
          // Remove connection
          this.activeConnections.delete(connectionId);
          
          // Update IP connection count
          if (ip) {
            const ipCount = this.ipConnections.get(ip) || 1;
            this.ipConnections.set(ip, Math.max(0, ipCount - 1));
          }
          
          info(`WebSocket disconnected: ${connectionId} with code ${code}`);
        }
      });
      
      // Send initial connection acknowledgment
      ws.send(JSON.stringify({
        type: 'connection_established',
        connectionId,
      }));
    });
  }

  async handleMessage(ws, data) {
    const connectionId = ws.connectionId;
    const connection = this.activeConnections.get(connectionId);
    
    if (!connection) {
      return this.sendError(ws, 'Connection not found');
    }
    
    // Update last activity timestamp
    connection.lastActivity = Date.now();
    
    // Handle message based on type
    switch (data.type) {
      case 'auth':
        await this.handleAuth(ws, connection, data);
        break;
        
      case 'heartbeat':
        this.handleHeartbeat(ws, connection);
        break;
        
      case 'join_session':
        if (!connection.authenticated) {
          return this.sendError(ws, 'Authentication required');
        }
        await this.handleJoinSession(ws, connection, data);
        break;
        
      case 'leave_session':
        if (!connection.authenticated) {
          return this.sendError(ws, 'Authentication required');
        }
        this.handleLeaveSession(ws, connection, data);
        break;
        
      case 'chat_message':
        if (!connection.authenticated || !connection.sessionId) {
          return this.sendError(ws, 'Authentication and active session required');
        }
        await this.handleChatMessage(ws, connection, data);
        break;
        
      case 'typing':
        if (!connection.authenticated || !connection.sessionId) {
          return this.sendError(ws, 'Authentication and active session required');
        }
        this.handleTypingIndicator(ws, connection, data);
        break;
        
      case 'invite_user':
        if (!connection.authenticated || !connection.sessionId) {
          return this.sendError(ws, 'Authentication and active session required');
        }
        await this.handleInviteUser(ws, connection, data);
        break;
        
      case 'remove_user':
        if (!connection.authenticated || !connection.sessionId) {
          return this.sendError(ws, 'Authentication and active session required');
        }
        this.handleRemoveUser(ws, connection, data);
        break;
        
      default:
        this.sendError(ws, `Unknown message type: ${data.type}`);
    }
  }

  async handleAuth(ws, connection, data) {
    try {
      const { userId, token } = data;
      
      if (!userId || !token) {
        return this.sendError(ws, 'Missing userId or token');
      }
      
      // Verify token
      const decoded = await verifyToken(token);
      
      if (!decoded || decoded.userId !== userId) {
        return this.sendError(ws, 'Invalid token');
      }
      
      // Update connection with authenticated user
      connection.userId = userId;
      connection.authenticated = true;
      
      // Send success response
      ws.send(JSON.stringify({
        type: 'auth_success',
        userId,
      }));
      
      info(`User authenticated: ${userId}`);
    } catch (error) {
      _error('Authentication error', error);
      this.sendError(ws, 'Authentication failed');
    }
  }

  handleHeartbeat(ws, connection) {
    ws.send(JSON.stringify({
      type: 'heartbeat_ack',
      timestamp: new Date().toISOString(),
    }));
  }

  async handleJoinSession(ws, connection, data) {
    try {
      const { sessionId, isHost, name, duration, isMultiUser } = data;
      
      if (!sessionId) {
        return this.sendError(ws, 'Missing sessionId');
      }
      
      // Check if session exists
      let session;
      
      if (this.chatSessions.has(sessionId)) {
        session = this.chatSessions.get(sessionId);
      } else {
        // Create new session if it doesn't exist
        session = {
          id: sessionId,
          hostId: isHost ? connection.userId : null,
          participants: [],
          messages: [],
          isMultiUser: isMultiUser || false,
          startTime: new Date(),
          duration: duration || 60, // Default 60 minutes
          isActive: true,
        };
        
        this.chatSessions.set(sessionId, session);
        
        // Add AI participant
        session.participants.push({
          userId: 'ai_assistant',
          name: 'KounselMe AI',
          isHost: false,
          isAI: true,
        });
      }
      
      // Check if user is already in session
      const existingParticipant = session.participants.find(p => p.userId === connection.userId);
      
      if (!existingParticipant) {
        // Add user to session
        session.participants.push({
          userId: connection.userId,
          name: name || connection.userId,
          isHost: isHost || false,
          isAI: false,
        });
      }
      
      // Update connection with session info
      connection.sessionId = sessionId;
      
      // Send session joined message
      ws.send(JSON.stringify({
        type: 'session_joined',
        sessionId,
        participants: session.participants,
      }));
      
      // Broadcast participant update to all session participants
      this.broadcastToSession(sessionId, {
        type: 'participant_update',
        participants: session.participants,
      }, null);
      
      // Send previous messages to new participant
      if (session.messages.length > 0) {
        for (const message of session.messages) {
          ws.send(JSON.stringify({
            type: 'chat_message',
            ...message,
          }));
        }
      }
      
      // If this is a new session, send AI greeting
      if (session.messages.length === 0 && isHost) {
        // Generate AI greeting
        const greeting = await this.aiService.generateGreeting();
        
        const aiMessage = {
          id: uuidv4(),
          sessionId,
          userId: 'ai_assistant',
          content: greeting,
          timestamp: new Date().toISOString(),
        };
        
        // Add to session messages
        session.messages.push(aiMessage);
        
        // Broadcast to all participants
        this.broadcastToSession(sessionId, {
          type: 'chat_message',
          ...aiMessage,
        }, null);
      }
      
      info(`User ${connection.userId} joined session ${sessionId}`);
    } catch (error) {
      _error('Error joining session', error);
      this.sendError(ws, 'Failed to join session');
    }
  }

  handleLeaveSession(ws, connection, data) {
    try {
      const { sessionId } = data;
      
      if (!sessionId || !connection.sessionId || sessionId !== connection.sessionId) {
        return this.sendError(ws, 'Invalid session');
      }
      
      this.leaveSession(connection.connectionId, sessionId);
      
      // Send confirmation
      ws.send(JSON.stringify({
        type: 'session_left',
        sessionId,
      }));
      
      info(`User ${connection.userId} left session ${sessionId}`);
    } catch (error) {
      _error('Error leaving session', error);
      this.sendError(ws, 'Failed to leave session');
    }
  }

  leaveSession(connectionId, sessionId) {
    const connection = this.activeConnections.get(connectionId);
    
    if (!connection) return;
    
    const session = this.chatSessions.get(sessionId);
    
    if (!session) return;
    
    // Remove participant from session
    const participantIndex = session.participants.findIndex(p => p.userId === connection.userId);
    
    if (participantIndex !== -1) {
      session.participants.splice(participantIndex, 1);
      
      // Broadcast participant update
      this.broadcastToSession(sessionId, {
        type: 'participant_update',
        participants: session.participants,
      }, null);
      
      // If host left and no other human participants, end session
      if (connection.userId === session.hostId && !session.participants.some(p => !p.isAI)) {
        session.isActive = false;
        
        // Broadcast session ended
        this.broadcastToSession(sessionId, {
          type: 'session_ended',
          sessionId,
          reason: 'Host left the session',
        }, null);
        
        // Remove session after a delay
        setTimeout(() => {
          this.chatSessions.delete(sessionId);
          info(`Session ${sessionId} removed after host left`);
        }, 60000); // Keep session for 1 minute for reconnection
      }
    }
    
    // Clear session from connection
    connection.sessionId = null;
  }

  async handleChatMessage(ws, connection, data) {
    try {
      const { sessionId, content, requestAIResponse = true } = data;
      
      if (!sessionId || !content) {
        return this.sendError(ws, 'Missing sessionId or content');
      }
      
      if (sessionId !== connection.sessionId) {
        return this.sendError(ws, 'Invalid session');
      }
      
      const session = this.chatSessions.get(sessionId);
      
      if (!session || !session.isActive) {
        return this.sendError(ws, 'Session not active');
      }
      
      // Create message
      const messageId = uuidv4();
      const timestamp = new Date().toISOString();
      
      const message = {
        id: messageId,
        sessionId,
        userId: connection.userId,
        content,
        timestamp,
      };
      
      // Add to session messages
      session.messages.push(message);
      
      // Broadcast to all participants
      this.broadcastToSession(sessionId, {
        type: 'chat_message',
        ...message,
      }, null);
      
      // Save message to database
      try {
        await ChatMessage.create({
          id: messageId,
          sessionId,
          userId: connection.userId,
          content,
          timestamp: new Date(timestamp),
        });
      } catch (dbError) {
        _error('Error saving message to database', dbError);
        // Continue even if database save fails
      }
      
      // Generate AI response if requested
      if (requestAIResponse) {
        // Send typing indicator from AI
        this.broadcastToSession(sessionId, {
          type: 'typing',
          userId: 'ai_assistant',
          isTyping: true,
        }, null);
        
        try {
          // Get context from previous messages
          const context = session.messages
            .slice(-10) // Last 10 messages for context
            .map(m => ({
              role: m.userId === 'ai_assistant' ? 'assistant' : 'user',
              content: m.content,
            }));
          
          // Generate AI response
          const aiResponse = await this.aiService.generateResponse(context);
          
          // Create AI message
          const aiMessageId = uuidv4();
          const aiTimestamp = new Date().toISOString();
          
          const aiMessage = {
            id: aiMessageId,
            sessionId,
            userId: 'ai_assistant',
            content: aiResponse,
            timestamp: aiTimestamp,
          };
          
          // Add to session messages
          session.messages.push(aiMessage);
          
          // Clear typing indicator
          this.broadcastToSession(sessionId, {
            type: 'typing',
            userId: 'ai_assistant',
            isTyping: false,
          }, null);
          
          // Broadcast AI response
          this.broadcastToSession(sessionId, {
            type: 'chat_message',
            ...aiMessage,
          }, null);
          
          // Save AI message to database
          try {
            await ChatMessage.create({
              id: aiMessageId,
              sessionId,
              userId: 'ai_assistant',
              content: aiResponse,
              timestamp: new Date(aiTimestamp),
            });
          } catch (dbError) {
            _error('Error saving AI message to database', dbError);
          }
        } catch (aiError) {
          _error('Error generating AI response', aiError);
          
          // Clear typing indicator
          this.broadcastToSession(sessionId, {
            type: 'typing',
            userId: 'ai_assistant',
            isTyping: false,
          }, null);
          
          // Send error message
          this.broadcastToSession(sessionId, {
            type: 'chat_message',
            id: uuidv4(),
            sessionId,
            userId: 'ai_assistant',
            content: "I'm sorry, I'm having trouble processing your request right now. Please try again in a moment.",
            timestamp: new Date().toISOString(),
          }, null);
        }
      }
    } catch (error) {
      _error('Error handling chat message', error);
      this.sendError(ws, 'Failed to process message');
    }
  }

  handleTypingIndicator(ws, connection, data) {
    try {
      const { sessionId, isTyping } = data;
      
      if (!sessionId || isTyping === undefined) {
        return this.sendError(ws, 'Missing sessionId or isTyping');
      }
      
      if (sessionId !== connection.sessionId) {
        return this.sendError(ws, 'Invalid session');
      }
      
      const session = this.chatSessions.get(sessionId);
      
      if (!session || !session.isActive) {
        return this.sendError(ws, 'Session not active');
      }
      
      // Broadcast typing indicator to all participants except sender
      this.broadcastToSession(sessionId, {
        type: 'typing',
        userId: connection.userId,
        isTyping,
      }, connection.connectionId);
    } catch (error) {
      _error('Error handling typing indicator', error);
      this.sendError(ws, 'Failed to process typing indicator');
    }
  }

  async handleInviteUser(ws, connection, data) {
    try {
      const { sessionId, email, message } = data;
      
      if (!sessionId || !email) {
        return this.sendError(ws, 'Missing sessionId or email');
      }
      
      if (sessionId !== connection.sessionId) {
        return this.sendError(ws, 'Invalid session');
      }
      
      const session = this.chatSessions.get(sessionId);
      
      if (!session || !session.isActive) {
        return this.sendError(ws, 'Session not active');
      }
      
      // Check if user is host
      if (session.hostId !== connection.userId) {
        return this.sendError(ws, 'Only host can invite users');
      }
      
      // Generate invite link
      const inviteToken = uuidv4();
      
      // TODO: Send email with invite link
      
      // Send confirmation
      ws.send(JSON.stringify({
        type: 'invite_sent',
        email,
        inviteToken,
      }));
      
      info(`User ${connection.userId} invited ${email} to session ${sessionId}`);
    } catch (error) {
      _error('Error inviting user', error);
      this.sendError(ws, 'Failed to invite user');
    }
  }

  handleRemoveUser(ws, connection, data) {
    try {
      const { sessionId, userId } = data;
      
      if (!sessionId || !userId) {
        return this.sendError(ws, 'Missing sessionId or userId');
      }
      
      if (sessionId !== connection.sessionId) {
        return this.sendError(ws, 'Invalid session');
      }
      
      const session = this.chatSessions.get(sessionId);
      
      if (!session || !session.isActive) {
        return this.sendError(ws, 'Session not active');
      }
      
      // Check if user is host
      if (session.hostId !== connection.userId) {
        return this.sendError(ws, 'Only host can remove users');
      }
      
      // Find user's connection
      let userConnectionId = null;
      
      for (const [connId, conn] of this.activeConnections.entries()) {
        if (conn.userId === userId && conn.sessionId === sessionId) {
          userConnectionId = connId;
          break;
        }
      }
      
      if (userConnectionId) {
        // Get user's connection
        const userConnection = this.activeConnections.get(userConnectionId);
        
        // Send removal notification
        const userWs = userConnection.ws;
        
        userWs.send(JSON.stringify({
          type: 'removed_from_session',
          sessionId,
          removedBy: connection.userId,
        }));
        
        // Remove from session
        this.leaveSession(userConnectionId, sessionId);
      }
      
      // Send confirmation to host
      ws.send(JSON.stringify({
        type: 'user_removed',
        sessionId,
        userId,
      }));
      
      info(`User ${userId} removed from session ${sessionId} by ${connection.userId}`);
    } catch (error) {
      _error('Error removing user', error);
      this.sendError(ws, 'Failed to remove user');
    }
  }

  broadcastToSession(sessionId, message, excludeConnectionId) {
    const session = this.chatSessions.get(sessionId);
    
    if (!session) return;
    
    // Convert message to string once
    const messageStr = JSON.stringify(message);
    
    // Send to all connections in session
    for (const [connId, conn] of this.activeConnections.entries()) {
      if (conn.sessionId === sessionId && connId !== excludeConnectionId) {
        try {
          conn.ws.send(messageStr);
        } catch (error) {
          _error(`Error sending message to connection ${connId}`, error);
        }
      }
    }
  }

  sendError(ws, message) {
    try {
      ws.send(JSON.stringify({
        type: 'error',
        message,
      }));
    } catch (error) {
      _error('Error sending error message', error);
    }
  }

  // Cleanup inactive connections
  startCleanupInterval() {
    setInterval(() => {
      const now = Date.now();
      
      for (const [connId, conn] of this.activeConnections.entries()) {
        // Check if connection is inactive for more than 5 minutes
        if (now - conn.lastActivity > 5 * 60 * 1000) {
          info(`Closing inactive connection: ${connId}`);
          
          try {
            // Remove from session if in one
            if (conn.sessionId && this.chatSessions.has(conn.sessionId)) {
              this.leaveSession(connId, conn.sessionId);
            }
            
            // Close connection
            conn.ws.close(1000, 'Inactive connection');
            
            // Remove from active connections
            this.activeConnections.delete(connId);
          } catch (error) {
            _error(`Error closing inactive connection ${connId}`, error);
          }
        }
      }
      
      // Clean up empty sessions
      for (const [sessionId, session] of this.chatSessions.entries()) {
        // Check if session has no human participants
        if (!session.participants.some(p => !p.isAI)) {
          info(`Removing empty session: ${sessionId}`);
          this.chatSessions.delete(sessionId);
        }
      }
    }, 60000); // Run every minute
  }
}

export default new WebSocketService();
