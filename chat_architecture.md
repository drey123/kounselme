1. Separation of Concerns
Frontend (Flutter):

UI/UX for chat interface
Local state management with Riverpod
WebSocket client for real-time communication
REST API client for chat session management
Local SQLite storage for offline chat history
Time management UI (monthly allowance, personal limits)

Backend (Node.js/Fastify):

REST API for chat session management
WebSocket server for real-time messaging
AI integration (GPT-4o for chat, DeepSeek for summarization)
Authentication and authorization with supabase
Neon PostgreSQL for chat history persistence
Time tracking and limits enforcement

2. Communication Flow

Chat Initialization:

User requests to start a chat via Flutter UI
Frontend sends request to backend API
Backend creates chat and returns chat ID
Frontend connects to WebSocket using chat ID
Backend prepares AI context and initial greeting


Real-time Messaging:

User sends message via Flutter UI
Frontend sends message to backend via WebSocket
Backend processes message with context management
Backend handles AI response generation (GPT-4o)
Backend broadcasts messages to all participants
Frontend receives and displays messages with animations


Time Management:

Backend tracks time usage per user
Frontend displays time used and remaining allowance
Backend enforces monthly and per-chat limits
Backend handles time purchases and plan upgrades



3. Multi-User Implementation

Invitation Flow:

Host generates invite via API
System creates secure one-time link
Recipient joins via link
Backend adds participant to WebSocket room
Backend manages permissions and visibility


Participant Management:

Backend tracks participant status and permissions
Frontend displays participant indicators
Host controls managed through secure API endpoints
Permission-based message broadcasting



4. Context Management

Local Processing:

Frontend maintains recent messages in memory
Backend manages sliding context window
Backend triggers DeepSeek summarization based on thresholds
Backend injects relevant context from user history and mood trend


AI Integration:

Structured prompting for GPT-4o while remove person info like banking deatils card number phone number sun[bstituition real name for user id but still calling them the real name in chat 
]
Whisper API for voice transcription
TTS for premium voice responses
DeepSeek for efficient summarization



5. Offline Support

Local Storage:

SQLite for complete chat history
Message queuing during disconnection
Background sync when connection restored
Local chat state preservation



6. Security Measures

Chat Security:

End-to-end encryption for multi-user chats
Secure WebSocket connections with authentication
Participant verification
Privacy controls for chat history



7. Implementation Phases

Phase 1: Core Chat

One-on-one AI chat functionality
Basic UI implementation
Time-based allowance system
Local and cloud storage


Phase 2: Multi-User Features

Invitation system
Participant management
Permission controls
Real-time presence indicators


Phase 3: Advanced Features

Voice mode integration
Enhanced context management
Time purchasing and plan management
Scheduling functionality



This architecture focuses exclusively on the chat functionality, providing a clear separation of concerns and implementation strategy to deliver a robust, scalable chat experience.