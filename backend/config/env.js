// backend/config/env.js
require('dotenv').config({
  path: process.env.NODE_ENV === 'production' 
    ? '.env.prod' 
    : '.env.dev'
});

/**
 * Environment configuration for the KounselMe backend
 * Provides easy access to environment variables with appropriate defaults
 */
const env = {
  // Server configuration
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '3000', 10),
  API_VERSION: process.env.API_VERSION || 'v1',
  
  // Database configuration
  DB_URL: process.env.NODE_ENV === 'production' 
    ? process.env.PROD_DB_URL 
    : process.env.DEV_DB_URL,
  
  // Authentication
  JWT_SECRET: process.env.JWT_SECRET || 'dev_secret_key_change_in_production',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  
  // API Keys
  OPENAI_API_KEY: process.env.OPENAI_API_KEY,
  TOGETHER_API_KEY: process.env.TOGETHER_API_KEY,
  
  // CORS configuration
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*',
  
  // Chat settings
  MAX_CONTEXT_MESSAGES: parseInt(process.env.MAX_CONTEXT_MESSAGES || '15', 10),
  DEFAULT_SESSION_LENGTH: parseInt(process.env.DEFAULT_SESSION_LENGTH || '30', 10), // minutes
  FREE_SESSION_COOLDOWN: parseInt(process.env.FREE_SESSION_COOLDOWN || '120', 10), // minutes
  
  // Logging
  LOG_LEVEL: process.env.LOG_LEVEL || 'info',
  
  // Helper method to check if we're in production
  isProd: () => process.env.NODE_ENV === 'production',
  
  // Helper method to check if we're in development
  isDev: () => process.env.NODE_ENV === 'development' || !process.env.NODE_ENV,
  
  // Helper method to check if we're in test
  isTest: () => process.env.NODE_ENV === 'test',
};

// Validate required environment variables in production
if (env.isProd()) {
  const requiredEnvVars = [
    'PORT', 
    'PROD_DB_URL', 
    'JWT_SECRET',
    'OPENAI_API_KEY'
  ];
  
  for (const varName of requiredEnvVars) {
    if (!process.env[varName]) {
      console.error(`Error: Environment variable ${varName} is required in production mode.`);
      process.exit(1);
    }
  }
}

module.exports = env;