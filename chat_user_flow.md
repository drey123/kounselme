# Improved KounselMe Chat User Flow

## 1. Chat Initiation Flow

### Starting a New Chat
1. User taps on Chat tab in main navigation
2. Home screen displays:
   - Monthly time balance indicator (e.g., "3h 15m remaining this month")
   - Large "Start Chat" button (primary focus)
   - "Schedule for Later" button (secondary option)
3. User taps "Start Chat"
4. Optional topic selection screen appears:
   - Suggested topics based on previous conversations
   - "Just chat" option to begin immediately
5. Chat interface opens with AI greeting message
6. Subtle timer begins in top center (incrementing, not counting down)
7. User can immediately begin typing or use voice input

### Accessing Chat History (Drawer)
1. User taps menu button in top-left or swipes from left edge
2. Drawer slides in showing previous chats:
   - Chat title or date
   - Short preview of first message
   - Duration of chat
3. Chats organized by recency (today, yesterday, this week, earlier)
4. Search bar at top of drawer for finding specific chats
5. User taps on previous chat to view in read-only mode
6. "Continue This Chat" button available if within monthly limit

### Scheduling a Chat
1. User taps "Schedule for Later" on home screen
2. Simple date/time picker appears
3. User selects preferred time
4. "Add to Calendar" option with platform-specific icons:
   - Apple Calendar icon for iOS
   - Google Calendar icon for Android
5. System creates local calendar event with reminder
6. At scheduled time, notification appears to start chat
7. No server resources used until user actually starts the chat

## 2. Chat Interaction Flow

### Text Messaging
1. User types in input field at bottom
2. Send button appears (replacing microphone)
3. User taps send
4. Message appears with subtle sending indicator
5. AI begins responding with typing indicator
5. AI begins responding with typing indicator
5a. For complex queries, system shows enhanced "Thinking deeply..." indicator:
   - Animated brain icon with pulsing effect
   - Progress bar or circular animation
   - Different color than standard typing indicator
   - Appears for responses requiring multiple API calls or complex reasoning
6. Response appears in chat bubble
7. Time usage counter updates subtly
8. All users as profile picture of the first letter of their name or image something

### Voice Input
1. User taps microphone button when input field is empty
2. Recording animation begins (pulsing mic icon)
3. User speaks message
4. User taps microphone again to end recording
5. Transcription appears in input field
6. User can edit text if needed
7. User taps send button to submit

### Multi-user Permissions
 System assigns clear permission levels with visual indicators:
   - Host: Full control (crown icon)
     • Can add/remove participants
     • Can export entire chat
     • Can end chat for everyone
     • Controls time usage settings
   - Participants: Standard permissions (person icon)
     • Can send/receive messages
     • Can only see chat history from when they joined
     • Cannot add others or access chat after removal unless signed up their part of their chat  will be in hisotry as read only
   

### Multi-user Chat
1. During chat, user taps "+" in quick actions or from more menu
2. Simple invite screen appears:
   - Email input field
   - Optional message field
   - Number of invites remaining indicator
2. System sends email with secure link
3. Recipient clicks link and is taken directly to chat
4. New participant sees option to:
   - Continue as guest
   - Sign up (simple email/password form)
5. All participants see notification: "[Name] joined the chat"
6. Host's time balance is used (not participants)
7. Host can remove participants if needed

## 3. Time Management Flow

### Monthly Time Allowance
1. Each plan includes fixed monthly time:
   - Free: 1 hour/month
   - Basic ($5): 5 hours/month
   - Family ($10): 10 hours/month
   - Team ($15): 15 hours/month
2. Time counter runs only during active conversation
3. System pauses counter after 30 seconds of inactivity
4. Time balance visible in home screen and subtly in chat header
5. System notifies at 75% usage with upgrade option

### Personal Time Budgeting
1. User can set custom time limits for individual chats:
   - Quick presets (5min, 15min, 30min) available
   - Custom duration option with number input
   - "Just this once" or "Save as default" options
2. System displays personal budget separate from monthly allowance:
   - Circular progress indicator shows custom limit
   - Color changes as approaching user-defined limit
   - Takes priority in UI over monthly limit display
3. When approaching personal limit (80%):
   - Gentle notification appears
   - Option to extend personal limit or end at planned time
4. Personal limits help users manage time mindfully while still using monthly allowance efficiently
5. Setting accessible via quick gear icon in chat header

### Time Limit Handling
1. When approaching limit (5 minutes remaining):
   - Subtle notification appears
   - Options: "Add Time" or "Continue"
2. When limit reached:
   - AI completes current response
   - System shows friendly message about time limit
   - Options: "Add More Time" or "End Chat"
3. "Add More Time" options:
   - 1 hour: $2
   - 3 hours: $5
   - Upgrade plan (shows plan comparison)
4. Payment processed through Lemon Squeezy
5. Chat continues immediately after payment

### Pausing/Resuming
1. Chat automatically pauses after 1 minute of inactivity
2. User can manually pause by closing app or navigating away
3. Time counter stops during pause
4. When user returns, chat is in exactly same state
5. AI briefly recaps conversation context if pause was long

## 4. Technical Resilience

### Connection Management
1. If connection lost during chat:
   - "Offline" indicator appears
   - User can continue typing
   - Messages queued locally
2. When connection restored:
   - Queued messages sent
   - AI receives all context
   - Time tracking resumes accurately

### Cross-device Experience
1. User can switch between devices seamlessly
2. Chat state and time usage synced across devices
3. Push notifications work across user's devices
4. Guests (non-signed-up participants) limited to web access

## 5. UI Button Implementation

### Primary Chat Screen
- **Menu Button** (top-left): Opens history drawer
- **Time Display** (top-center): Shows time used in current chat and monthly remaining
- **Participants** (top-right): Shows avatars of active participants with count
- **More Menu** (top-right): Additional options
  - Add Participants
  - Schedule Next Chat
  - Export Chat
  - End Chat

### Input Area
- **Quick Actions Toggle** (bottom-left): Expands/collapses action bar
- **Text Input Field** (bottom-center): Expandable, multi-line
- **Voice/Send Button** (bottom-right): Context-aware (mic when empty, send when text entered)

### Quick Actions Bar
- **Add Participant** button
- **Share Link** button (creates shareable link)
- **Upload** button (for images/files)
- **Reminder** button (sets notification for follow-up)

### Additional Controls
- **Add to Calendar** buttons (iOS/Android specific) in scheduling screen
- **Time Purchase** options when limit reached
- **Continue as Guest/Sign Up** options for invitees

This streamlined flow focuses on a time-based approach rather than rigid sessions, maintains the familiar drawer pattern you like, integrates calendar functions simply, and provides clear paths for multi-user participation while keeping the overall experience intuitive and focused on conversation rather than time management.