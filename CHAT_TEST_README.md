# KounselMe Chat Test Instructions

This document provides instructions on how to test the chat functionality in isolation, without being affected by errors from other screens that haven't been updated yet.

## Why Test in Isolation?

The chat functionality has been updated with the latest improvements, but other screens in the app may still have issues with the updated theme and other components. Testing the chat in isolation allows you to focus on the chat functionality without being affected by these issues.

## How to Run the Chat Test

### Option 1: Using the Batch File (Windows)

1. Open a command prompt in the project root directory
2. Run the batch file:
   ```
   run_chat_test.bat
   ```

### Option 2: Using the PowerShell Script (Windows)

1. Open PowerShell in the project root directory
2. Run the PowerShell script:
   ```
   .\run_chat_test.ps1
   ```

### Option 3: Using Flutter Command Directly

1. Open a terminal in the project root directory
2. Run the following command:
   ```
   flutter run -t lib/chat_test_app.dart
   ```

## What to Test

### 1. Chat Interface
- Verify that the chat interface loads correctly
- Check that the message bubbles display properly
- Test the chat input field for text entry

### 2. Voice Input
- Test the voice input functionality by tapping the microphone icon
- Verify that the voice input modal appears
- Check that the waveform visualization works
- Test the real-time transcription display

### 3. Message Types
- Test sending different types of messages (text, voice)
- Verify that system messages display correctly
- Check that message status indicators work (sending, delivered, failed)

### 4. Chat History
- Open the chat history drawer by tapping the menu button
- Verify that the chat history displays correctly
- Test the search functionality in the drawer

### 5. Session Management
- Check that the session timer displays correctly
- Test the session start/end functionality
- Verify that time tracking works properly

## Troubleshooting

If you encounter any issues while testing:

1. Check the terminal output for error messages
2. Make sure you're running the chat test app and not the main app
3. Try restarting the app with the `--no-sound-null-safety` flag if needed:
   ```
   flutter run -t lib/chat_test_app.dart --no-sound-null-safety
   ```

## Reporting Issues

When reporting issues with the chat functionality, please include:

1. A description of the issue
2. Steps to reproduce the issue
3. Screenshots if applicable
4. Terminal output/logs

## Next Steps

After testing the chat functionality in isolation, we'll work on updating the other screens to be compatible with the latest improvements.
