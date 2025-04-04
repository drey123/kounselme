# KounselMe

KounselMe is an AI-powered mental wellness application that provides support through chat, mood tracking, and journaling capabilities.

## Features

- 🤖 **AI Counseling Chat**: Talk through challenges with a supportive AI companion
- 📔 **Journal**: Write and reflect on your thoughts with a digital journal
- 📊 **Mood Tracking**: Track and visualize your mood patterns over time
- 👤 **User Profiles**: Personalized experience with secure user accounts
- 🎨 **Elegant UI**: Beautiful, intuitive interface designed for mental wellness

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or above)
- Dart SDK (3.0.0 or above)
- An editor (VS Code, Android Studio, etc.)
- Supabase account (for backend services)

### Installation

1. Clone the repository
   ```
   git clone https://github.com/yourusername/kounselme.git
   cd kounselme
   ```

2. Set up environment variables
   ```
   cp .env.example .env
   ```
   Edit the `.env` file with your Supabase and API credentials.

3. Install dependencies
   ```
   flutter pub get
   ```

4. Run the application
   ```
   flutter run
   ```

## Project Structure

- `/lib/config` - App configuration files
- `/lib/core` - Core utilities and constants
- `/lib/data` - Data models, services, and repositories
- `/lib/presentation` - UI components (screens, widgets)
- `/assets` - Static assets (fonts, images)

## Development

### Running in Development Mode

The app includes a development toggle in `main.dart` to bypass authentication:

```dart
// Set to true to bypass auth screens during development
const bool kDevMode = true;
```

### Technologies Used

- **Flutter & Dart** - UI framework
- **Riverpod** - State management
- **Supabase** - Backend & authentication
- **SQLite** - Local data storage

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
