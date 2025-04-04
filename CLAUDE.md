# KounselMe Project Guide

This document provides guidance for Claude when working with this codebase.

## Project Overview
KounselMe is a Flutter-based mental wellness application featuring:
- AI-powered chatbot for counseling conversations
- Mood tracking and visualization
- Journaling capabilities
- User authentication and profile management

## Key Commands
- Run app: `flutter run`
- Build app: `flutter build apk`
- Format code: `flutter format .`
- Analyze code: `flutter analyze`
- Run tests: `flutter test`

## File Structure
- `lib/`: Main source code
  - `config/`: App configuration
  - `core/`: Core utilities and constants
  - `data/`: Data models and services
  - `presentation/`: UI screens and widgets
- `assets/`: Static assets like fonts and images
- `test/`: Test files

## Code Conventions
- Use camelCase for variable and function names
- Prefix widgets with 'K' (e.g., KButton)
- Keep UI components modular and reusable
- Follow Flutter best practices for state management

## Dependencies
Check pubspec.yaml for the full list of dependencies.

# UI Design
- App is undergoing UI redesign, adapting Mindify UI patterns while maintaining KounselMe branding
- Keep established brand colors (electric violet, heliotrope, robins green, etc.)
- Use Inter and Manrope fonts (not Urbanist/Playfair/Roboto)
- Reference designs in `/infoaboutcode/uimindify/` for layout and component patterns
- Apply KounselMe brand identity to the Mindify UI structure

# Branding & UI
- User wants to maintain KounselMe branding while adapting the Mindify UI designs
- User wants the chat UI to follow a ChatGPT/Claude AI style interface with conversation history, modals for invites, and session management features
- User wants a ChatGPT-style chat UI with toggle features and quick icon selectors in the text bar area for functions like timer
- User wants a ChatGPT-style chat UI with sliding history panel and voice mode that changes to send mode when text is entered, with button becoming unpressable during AI responses
- Always ensure responsive design across all device types including mobile (Android/iPhone), tablets (iPad), and web dimensions
- Always ensure responsive design and modern UI that follows Apple's Human Interface Guidelines, with adaptive layouts, proper text sizing, and high-quality visual elements
- The project uses Inter and Manrope fonts for UI elements
- User reported fading text/icons on iPhone 12, requiring investigation of font implementation across codebase
- User wants modern, clean, high-definition UI styling that looks smooth and glassy across all devices, with a chatreport.md file to track chat feature changes

# Business Model & Features


# Technical Architecture & Development
- User wants to separate backend development from Flutter frontend, ensure app follows best practices for Apple/Android compliance, and utilize UI assets from uimindify folder along with creating reusable widgets
- User is evaluating timing of backend implementation
- Always check infoaboutcode folder first as it contains old designs, new designs, and other critical information before making changes or suggestions
- Always update the project_status.md file in the infoaboutcode folder as we progress through development to maintain a clear overview of what's working, what's in progress, and what issues need to be addressed
- Focus on completing the chat design before implementing environment separation (dev/prod)
- User wants a chatreport.md file to track chat feature changes and a log file to record Flutter run terminal output for debugging
- PowerShell's Tee-Object will append to log files rather than clearing previous content
- User prefers to launch Android emulators directly from VS Code rather than standalone Android Studio
- User prefers simple, direct approaches when debugging - run commands directly and check terminal output without complicated processes