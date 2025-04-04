// backend/server.js
const fastify = require('fastify')({ 
  logger: false,
  ajv: {
    customOptions: {
      removeAdditional: 'all',
      useDefaults: true,
      coerceTypes: true,
      allErrors: true
    }
  }
});
const env = require('./config/env');
const logger = require('./src/utils/logger');
const { setupWebSocketServer } = require('./src/services/websocket.service');

// Register plugins
fastify.register(require('@fastify/cors'), {
  origin: env.CORS_ORIGIN.split(','),
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
});

fastify.register(require('@fastify/helmet'));
fastify.register(require('@fastify/sensible'));
fastify.register(require('@fastify/rate-limit'), {
  max: 100,
  timeWindow: '15 minutes'
});

// Health check route
fastify.get('/health', async () => {
  return { 
    status: 'UP', 
    environment: env.NODE_ENV,
    timestamp: new Date().toISOString()
  };
});

// API routes prefix
const apiPrefix = `/api/${env.API_VERSION}`;

// Register route plugins
fastify.register(require('./src/routes/session.routes'), { prefix: apiPrefix });
// Additional routes will be registered here as they are developed

// Error handler
fastify.setErrorHandler((error, request, reply) => {
  logger.error(`Error: ${error.message}`, { 
    stack: error.stack,
    path: request.url
  });
  
  // Send error response
  const statusCode = error.statusCode || 500;
  const message = env.isProd() && statusCode === 500 
    ? 'An unexpected error occurred' 
    : error.message;
    
  reply.status(statusCode).send({
    status: 'error',
    message,
    ...(env.isDev() && { stack: error.stack })
  });
});

// Not found handler
fastify.setNotFoundHandler((request, reply) => {
  reply.status(404).send({ 
    status: 'error',
    message: 'Route not found' 
  });
});

// Request logging middleware
fastify.addHook('onRequest', (request, reply, done) => {
  logger.info(`${request.method} ${request.url}`);
  done();
});

// Response logging middleware
fastify.addHook('onResponse', (request, reply, done) => {
  logger.info(`${request.method} ${request.url} - ${reply.statusCode}`);
  done();
});

// Start the server
const start = async () => {
  try {
    await fastify.listen({ port: env.PORT, host: '0.0.0.0' });
    logger.info(`KounselMe API server running on port ${env.PORT} in ${env.NODE_ENV} mode`);
    
    // Start WebSocket server
    setupWebSocketServer();
    logger.info('WebSocket server initialized');
  } catch (err) {
    logger.error('Error starting server:', err);
    process.exit(1);
  }
};

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  await fastify.close();
  logger.info('Process terminated');
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully');
  await fastify.close();
  logger.info('Process terminated');
  process.exit(0);
});

// Start server
start();