// backend/src/controllers/session.controller.js
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const env = require('../../config/env');

// In-memory session store (would be replaced with database in production)
const sessions = new Map();

/**
 * Create a new chat session
 */
async function createSession(request, reply) {
  try {
    const { userId, duration, isMultiUser, title } = request.body;
    
    // Validate request
    if (!userId) {
      return reply.badRequest('User ID is required');
    }
    
    // Create session ID
    const sessionId = uuidv4();
    
    // Create session
    const session = {
      id: sessionId,
      title: title || 'Therapy Session',
      createdAt: new Date().toISOString(),
      duration: duration || env.DEFAULT_SESSION_LENGTH,
      isMultiUser: isMultiUser || false,
      participants: [
        {
          userId,
          isHost: true,
          joinedAt: new Date().toISOString()
        }
      ],
      messageCount: 0
    };
    
    // Store session
    sessions.set(sessionId, session);
    
    logger.info(`Session created: ${sessionId} by user ${userId}`);
    
    return reply.code(201).send({
      success: true,
      session: {
        id: sessionId,
        title: session.title,
        createdAt: session.createdAt,
        duration: session.duration,
        isMultiUser: session.isMultiUser
      }
    });
  } catch (error) {
    logger.error('Error creating session:', error);
    return reply.internalServerError('Error creating session');
  }
}

/**
 * Get session details
 */
async function getSession(request, reply) {
  try {
    const { id } = request.params;
    
    // Check if session exists
    if (!sessions.has(id)) {
      return reply.notFound('Session not found');
    }
    
    const session = sessions.get(id);
    
    return reply.send({
      success: true,
      session: {
        id: session.id,
        title: session.title,
        createdAt: session.createdAt,
        duration: session.duration,
        isMultiUser: session.isMultiUser,
        participants: session.participants,
        messageCount: session.messageCount
      }
    });
  } catch (error) {
    logger.error('Error getting session:', error);
    return reply.internalServerError('Error getting session');
  }
}

/**
 * End a session
 */
async function endSession(request, reply) {
  try {
    const { id } = request.params;
    const { userId } = request.body;
    
    // Check if session exists
    if (!sessions.has(id)) {
      return reply.notFound('Session not found');
    }
    
    const session = sessions.get(id);
    
    // Check if user is host
    const isHost = session.participants.some(p => p.userId === userId && p.isHost);
    
    if (!isHost) {
      return reply.forbidden('Only the host can end the session');
    }
    
    // Update session end time
    session.endedAt = new Date().toISOString();
    
    logger.info(`Session ended: ${id} by user ${userId}`);
    
    return reply.send({
      success: true,
      message: 'Session ended successfully'
    });
  } catch (error) {
    logger.error('Error ending session:', error);
    return reply.internalServerError('Error ending session');
  }
}

/**
 * Get user's recent sessions
 */
async function getUserSessions(request, reply) {
  try {
    const { userId } = request.params;
    
    // Filter sessions by user participation
    const userSessions = Array.from(sessions.values())
      .filter(session => session.participants.some(p => p.userId === userId))
      .map(session => ({
        id: session.id,
        title: session.title,
        createdAt: session.createdAt,
        endedAt: session.endedAt,
        duration: session.duration,
        isMultiUser: session.isMultiUser,
        participantCount: session.participants.length,
        messageCount: session.messageCount
      }))
      // Sort by most recent first
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      // Limit to 10 most recent
      .slice(0, 10);
    
    return reply.send({
      success: true,
      sessions: userSessions
    });
  } catch (error) {
    logger.error('Error getting user sessions:', error);
    return reply.internalServerError('Error getting user sessions');
  }
}

/**
 * Check if user can start a new session
 */
async function checkSessionAvailability(request, reply) {
  try {
    const { userId } = request.params;
    
    // Get user's recent sessions
    const userSessions = Array.from(sessions.values())
      .filter(session => {
        return session.participants.some(p => p.userId === userId) && 
               !session.endedAt;  // Only consider active sessions
      });
    
    // Check if user has an active session
    const hasActiveSession = userSessions.length > 0;
    
    // Calculate time until next free session
    // This is a simplified version - in a real app, you would check user's subscription
    // and compute the actual cooldown based on that
    let nextFreeSession = null;
    
    if (hasActiveSession) {
      // If has active session, user must wait for it to end
      nextFreeSession = 'You have an active session that must end first';
    } else {
      // Check when the most recent session ended
      const endedSessions = Array.from(sessions.values())
        .filter(session => {
          return session.participants.some(p => p.userId === userId) && 
                 session.endedAt;
        })
        .sort((a, b) => new Date(b.endedAt) - new Date(a.endedAt));
      
      if (endedSessions.length > 0) {
        const mostRecentSession = endedSessions[0];
        const endTime = new Date(mostRecentSession.endedAt);
        const cooldownEnd = new Date(endTime.getTime() + env.FREE_SESSION_COOLDOWN * 60 * 1000);
        
        if (cooldownEnd > new Date()) {
          // User is still in cooldown
          nextFreeSession = cooldownEnd.toISOString();
        }
      }
    }
    
    return reply.send({
      success: true,
      canStartSession: !hasActiveSession && !nextFreeSession,
      nextFreeSession,
      hasActiveSession,
      remainingSessions: 3  // Placeholder for subscription-based limit
    });
  } catch (error) {
    logger.error('Error checking session availability:', error);
    return reply.internalServerError('Error checking session availability');
  }
}

module.exports = {
  createSession,
  getSession,
  endSession,
  getUserSessions,
  checkSessionAvailability
};