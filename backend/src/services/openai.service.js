// backend/src/services/openai.service.js
const OpenAI = require('openai');
const logger = require('../utils/logger');
const env = require('../../config/env');

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: env.OPENAI_API_KEY
});

/**
 * Get a response from the OpenAI chat model
 * 
 * @param {Array} messages - Array of previous messages for context
 * @returns {Promise<string>} - AI response text
 */
async function getChatResponse(messages) {
  try {
    // System message to guide the AI's behavior
    const systemPrompt = `You are KounselMe, a compassionate and supportive AI mental health assistant. 
Your goal is to provide empathetic listening, ask thoughtful questions, and offer evidence-based 
coping strategies for common mental health concerns.

Guidelines:
- Be warm, supportive, and non-judgmental
- Use a conversational, friendly tone
- Focus on active listening and validation
- Ask open-ended questions to encourage reflection
- Offer practical coping strategies based on CBT, mindfulness, and positive psychology
- Recognize your limitations and do not position yourself as a replacement for professional help
- If someone expresses thoughts of self-harm or suicide, emphasize the importance of reaching out to crisis services

Remember you're in a therapeutic conversation where the user's wellbeing is the priority.`;

    // Format conversation history for the API
    const formattedMessages = [
      { role: 'system', content: systemPrompt },
      // Add relevant context messages
      ...messages.map(msg => ({
        role: msg.isUser ? 'user' : 'assistant',
        content: msg.content
      }))
    ];

    // Call the API
    const response = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: formattedMessages,
      temperature: 0.7,
      max_tokens: 1000,
      top_p: 1,
    });

    const responseText = response.choices[0].message.content.trim();
    return responseText;
  } catch (error) {
    logger.error('Error calling OpenAI API:', error);
    throw new Error('Failed to get AI response');
  }
}

/**
 * Get a summary of the conversation for context window management
 * 
 * @param {Array} messages - Array of messages to summarize
 * @returns {Promise<string>} - Summary text
 */
async function getConversationSummary(messages) {
  try {
    const conversationText = messages.map(msg => 
      `${msg.isUser ? 'User' : 'Assistant'}: ${msg.content}`
    ).join('\n\n');

    const response = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: `Summarize the following conversation between a user and an AI mental health assistant. 
Focus on key points, emotions expressed, and any important information shared. 
Keep the summary concise but include all relevant details to maintain context.`
        },
        {
          role: 'user',
          content: conversationText
        }
      ],
      temperature: 0.3,
      max_tokens: 500
    });

    return response.choices[0].message.content.trim();
  } catch (error) {
    logger.error('Error generating conversation summary:', error);
    throw new Error('Failed to summarize conversation');
  }
}

/**
 * Convert speech to text using Whisper
 * 
 * @param {Buffer} audioBuffer - Audio buffer to transcribe
 * @returns {Promise<string>} - Transcribed text
 */
async function transcribeSpeech(audioBuffer) {
  try {
    const response = await openai.audio.transcriptions.create({
      file: audioBuffer,
      model: 'whisper-1',
      language: 'en',
    });

    return response.text;
  } catch (error) {
    logger.error('Error transcribing speech:', error);
    throw new Error('Failed to transcribe speech');
  }
}

module.exports = {
  getChatResponse,
  getConversationSummary,
  transcribeSpeech
};