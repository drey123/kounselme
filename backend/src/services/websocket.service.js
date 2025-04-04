// backend/src/services/websocket.service.js
const uWS = require('uWebSockets.js');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const env = require('../../config/env');
const openaiService = require('./openai.service');

// Store active connections
const activeConnections = new Map();

// Store chat sessions
const chatSessions = new Map();

/**
 * Set up WebSocket server for real-time chat
 */
function setupWebSocketServer() {
  // Create WebSocket app
  const app = uWS.App();
  
  // Set up WebSocket route
  app.ws('/chat', {
    /* Options */
    compression: 0,
    maxPayloadLength: 16 * 1024 * 1024, // 16MB
    idleTimeout: 120, // 2 minutes
    
    /* Handlers */
    open: (ws) => {
      const connectionId = uuidv4();
      
      // Store connection ID directly on ws object for reference in other handlers
      ws.connectionId = connectionId;
      
      // Store connection information
      activeConnections.set(connectionId, {
        ws,
        userId: null,
        sessionId: null,
        isAuthenticated: false
      });
      
      logger.info(`WebSocket connected: ${connectionId}`);
    },
    
    message: async (ws, message, isBinary) => {
      try {
        if (isBinary) {
          return sendError(ws, 'Binary messages not supported');
        }
        
        const messageText = Buffer.from(message).toString();
        const data = JSON.parse(messageText);
        
        // Handle message based on type
        switch (data.type) {
          case 'auth':
            handleAuthentication(ws, data);
            break;
          case 'join_session':
            handleJoinSession(ws, data);
            break;
          case 'leave_session':
            handleLeaveSession(ws, data);
            break;
          case 'chat_message':
            await handleChatMessage(ws, data);
            break;
          case 'typing':
            handleTypingEvent(ws, data);
            break;
          default:
            sendError(ws, 'Unknown message type');
        }
      } catch (error) {
        logger.error('Error processing WebSocket message', error);
        sendError(ws, 'Error processing message');
      }
    },
    
    drain: (ws) => {
      logger.info(`WebSocket backpressure: ${ws.getBufferedAmount()}`);
    },
    
    close: (ws, code, message) => {
      const connectionId = ws.connectionId;
      
      if (activeConnections.has(connectionId)) {
        const connection = activeConnections.get(connectionId);
        
        // Remove from session if in one
        if (connection.sessionId && chatSessions.has(connection.sessionId)) {
          leaveSession(connectionId, connection.sessionId);
        }
        
        // Remove connection
        activeConnections.delete(connectionId);
        
        logger.info(`WebSocket disconnected: ${connectionId} with code ${code}`);
      }
    }
  });
  
  // Listen on WebSocket port (HTTP port + 1)
  const wsPort = parseInt(env.PORT, 10) + 1;
  
  app.listen(wsPort, (listenSocket) => {
    if (listenSocket) {
      logger.info(`WebSocket server listening on port ${wsPort}`);
    } else {
      logger.error(`WebSocket server failed to listen on port ${wsPort}`);
    }
  });
  
  return app;
}

/**
 * Handle user authentication
 */
function handleAuthentication(ws, data) {
  // In a real implementation, verify the token with your auth service
  // This is a simplified example
  const connectionId = ws.connectionId;
  const connection = activeConnections.get(connectionId);
  
  if (!connection) return;
  
  // Validate token (simplified here)
  if (data.token) {
    connection.userId = data.userId;
    connection.isAuthenticated = true;
    
    sendToClient(ws, {
      type: 'auth_success',
      userId: data.userId
    });
    
    logger.info(`User authenticated: ${data.userId}`);
  } else {
    sendError(ws, 'Invalid authentication token');
  }
}

/**
 * Handle joining a chat session
 */
function handleJoinSession(ws, data) {
  const connectionId = ws.connectionId;
  const connection = activeConnections.get(connectionId);
  const sessionId = data.sessionId;
  
  if (!connection) return;
  
  // Require authentication
  if (!connection.isAuthenticated) {
    return sendError(ws, 'Authentication required');
  }
  
  // Create session if it doesn't exist
  if (!chatSessions.has(sessionId)) {
    chatSessions.set(sessionId, {
      id: sessionId,
      participants: new Map(),
      messages: [],
      createdAt: new Date().toISOString(),
      duration: data.duration || env.DEFAULT_SESSION_LENGTH,
      isMultiUser: data.isMultiUser || false
    });
    
    logger.info(`New session created: ${sessionId}`);
  }
  
  const session = chatSessions.get(sessionId);
  
  // Add participant to session
  session.participants.set(connectionId, {
    connectionId,
    userId: connection.userId,
    name: data.name || connection.userId,
    isHost: data.isHost || false,
    joinedAt: new Date().toISOString()
  });
  
  // Update connection with session info
  connection.sessionId = sessionId;
  
  // Send session info to client
  sendToClient(ws, {
    type: 'session_joined',
    sessionId,
    participants: Array.from(session.participants.values()),
    messages: session.messages,
    duration: session.duration,
    isMultiUser: session.isMultiUser
  });
  
  // Notify others in the session
  broadcastToSession(sessionId, {
    type: 'participant_joined',
    sessionId,
    participant: {
      userId: connection.userId,
      name: data.name || connection.userId,
      isHost: data.isHost || false
    }
  }, connectionId);
  
  logger.info(`User ${connection.userId} joined session ${sessionId}`);
}

/**
 * Handle leaving a chat session
 */
function handleLeaveSession(ws, data) {
  const connectionId = ws.connectionId;
  const connection = activeConnections.get(connectionId);
  
  if (!connection || !connection.sessionId) return;
  
  const sessionId = connection.sessionId;
  leaveSession(connectionId, sessionId);
}

/**
 * Helper to remove participant from session
 */
function leaveSession(connectionId, sessionId) {
  const connection = activeConnections.get(connectionId);
  const session = chatSessions.get(sessionId);
  
  if (!connection || !session) return;
  
  // Remove participant from session
  session.participants.delete(connectionId);
  
  // Clear session from connection
  connection.sessionId = null;
  
  // Notify others in the session
  broadcastToSession(sessionId, {
    type: 'participant_left',
    sessionId,
    userId: connection.userId
  });
  
  logger.info(`User ${connection.userId} left session ${sessionId}`);
  
  // If session empty, remove it
  if (session.participants.size === 0) {
    chatSessions.delete(sessionId);
    logger.info(`Session ${sessionId} removed (no participants)`);
  }
}

/**
 * Handle chat messages and AI responses
 */
async function handleChatMessage(ws, data) {
  const connectionId = ws.connectionId;
  const connection = activeConnections.get(connectionId);
  
  if (!connection || !connection.sessionId) {
    return sendError(ws, 'Not in an active session');
  }
  
  const sessionId = connection.sessionId;
  const session = chatSessions.get(sessionId);
  
  if (!session) {
    return sendError(ws, 'Session not found');
  }
  
  // Create message object
  const message = {
    id: uuidv4(),
    content: data.content,
    userId: connection.userId,
    isUser: true,
    timestamp: new Date().toISOString()
  };
  
  // Add message to session
  session.messages.push(message);
  
  // Broadcast message to all participants
  broadcastToSession(sessionId, {
    type: 'new_message',
    sessionId,
    message
  });
  
  // If the message is for AI, generate a response
  if (!session.isMultiUser || data.requestAIResponse) {
    // Send typing indicator
    broadcastToSession(sessionId, {
      type: 'typing',
      sessionId,
      userId: 'ai',
      isTyping: true
    });
    
    try {
      // Get AI response using context of recent messages
      const recentMessages = session.messages.slice(-env.MAX_CONTEXT_MESSAGES);
      const aiResponse = await openaiService.getChatResponse(recentMessages);
      
      // Create AI message
      const aiMessage = {
        id: uuidv4(),
        content: aiResponse,
        userId: 'ai',
        isUser: false,
        timestamp: new Date().toISOString()
      };
      
      // Add AI message to session
      session.messages.push(aiMessage);
      
      // Stop typing indicator
      broadcastToSession(sessionId, {
        type: 'typing',
        sessionId,
        userId: 'ai',
        isTyping: false
      });
      
      // Send AI message to all participants
      broadcastToSession(sessionId, {
        type: 'new_message',
        sessionId,
        message: aiMessage
      });
    } catch (error) {
      logger.error('Error getting AI response', error);
      
      // Stop typing indicator
      broadcastToSession(sessionId, {
        type: 'typing',
        sessionId,
        userId: 'ai',
        isTyping: false
      });
      
      // Send error to user who made the request
      sendError(ws, 'Failed to get AI response');
    }
  }
}

/**
 * Handle typing indicators
 */
function handleTypingEvent(ws, data) {
  const connectionId = ws.connectionId;
  const connection = activeConnections.get(connectionId);
  
  if (!connection || !connection.sessionId) return;
  
  const sessionId = connection.sessionId;
  
  // Broadcast typing status to all participants except sender
  broadcastToSession(sessionId, {
    type: 'typing',
    sessionId,
    userId: connection.userId,
    isTyping: data.isTyping
  }, connectionId);
}

/**
 * Send message to a client
 */
function sendToClient(ws, message) {
  const messageStr = JSON.stringify(message);
  ws.send(messageStr);
}

/**
 * Send error to a client
 */
function sendError(ws, message) {
  sendToClient(ws, {
    type: 'error',
    message
  });
}

/**
 * Broadcast message to all participants in a session
 */
function broadcastToSession(sessionId, message, excludeConnectionId = null) {
  const session = chatSessions.get(sessionId);
  if (!session) return;
  
  const messageStr = JSON.stringify(message);
  
  for (const [connId, participant] of session.participants) {
    if (connId !== excludeConnectionId) {
      const connection = activeConnections.get(connId);
      if (connection && connection.ws) {
        connection.ws.send(messageStr);
      }
    }
  }
}

module.exports = {
  setupWebSocketServer,
  // For testing
  _internal: {
    activeConnections,
    chatSessions
  }
};