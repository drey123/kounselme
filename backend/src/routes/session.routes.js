// backend/src/routes/session.routes.js
const sessionController = require('../controllers/session.controller');

/**
 * Session routes handler
 * 
 * @param {FastifyInstance} fastify - Fastify instance
 * @param {Object} options - Route options
 */
async function routes(fastify, options) {
  // Create a new session
  fastify.post('/sessions', {
    schema: {
      body: {
        type: 'object',
        required: ['userId'],
        properties: {
          userId: { type: 'string' },
          duration: { type: 'integer' },
          isMultiUser: { type: 'boolean' },
          title: { type: 'string' }
        }
      },
      response: {
        201: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            session: {
              type: 'object',
              properties: {
                id: { type: 'string' },
                title: { type: 'string' },
                createdAt: { type: 'string' },
                duration: { type: 'integer' },
                isMultiUser: { type: 'boolean' }
              }
            }
          }
        }
      }
    }
  }, sessionController.createSession);

  // Get session details
  fastify.get('/sessions/:id', {
    schema: {
      params: {
        type: 'object',
        required: ['id'],
        properties: {
          id: { type: 'string' }
        }
      },
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            session: { type: 'object' }
          }
        }
      }
    }
  }, sessionController.getSession);

  // End a session
  fastify.put('/sessions/:id/end', {
    schema: {
      params: {
        type: 'object',
        required: ['id'],
        properties: {
          id: { type: 'string' }
        }
      },
      body: {
        type: 'object',
        required: ['userId'],
        properties: {
          userId: { type: 'string' }
        }
      },
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            message: { type: 'string' }
          }
        }
      }
    }
  }, sessionController.endSession);

  // Get user's recent sessions
  fastify.get('/users/:userId/sessions', {
    schema: {
      params: {
        type: 'object',
        required: ['userId'],
        properties: {
          userId: { type: 'string' }
        }
      },
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            sessions: { type: 'array' }
          }
        }
      }
    }
  }, sessionController.getUserSessions);

  // Check session availability
  fastify.get('/users/:userId/session-availability', {
    schema: {
      params: {
        type: 'object',
        required: ['userId'],
        properties: {
          userId: { type: 'string' }
        }
      },
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            canStartSession: { type: 'boolean' },
            nextFreeSession: { type: ['string', 'null'] },
            hasActiveSession: { type: 'boolean' },
            remainingSessions: { type: 'integer' }
          }
        }
      }
    }
  }, sessionController.checkSessionAvailability);
}

module.exports = routes;