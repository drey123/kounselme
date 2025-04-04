# KounselMe Code Issues Report

*Last Updated: June 2024*

## Overview
This document tracks all code issues that need to be fixed in the KounselMe app. Issues are organized by category and severity.

## Fixed Issues ✅

### Iconsax Package References
The following files have been updated to replace Iconsax with AppIcons:

- ✅ lib/presentation/screens/home/home_screen.dart
- ✅ lib/presentation/screens/home/home_screen_fixed.dart
- ✅ lib/presentation/screens/chat/session_start_screen.dart
- ✅ lib/presentation/widgets/chat/k_invite_modal.dart
- ✅ lib/presentation/screens/chat/chat_screen.dart
- ✅ lib/presentation/screens/profile/profile_screen.dart
- ✅ lib/presentation/screens/journal/journal_screen.dart
- ✅ lib/presentation/screens/mood/mood_screen.dart
- ✅ lib/presentation/widgets/chat/k_voice_input.dart

### withOpacity() Usage
The following files have been updated to replace deprecated withOpacity() calls:

- ✅ lib/presentation/screens/home/home_screen.dart
- ✅ lib/presentation/screens/home/home_screen_fixed.dart
- ✅ lib/presentation/screens/chat/session_start_screen.dart
- ✅ lib/presentation/screens/chat/chat_screen.dart
- ✅ lib/presentation/widgets/chat/k_chat_input.dart
- ✅ lib/presentation/widgets/chat/k_message_bubble.dart
- ✅ lib/presentation/widgets/chat/k_time_display.dart
- ✅ lib/presentation/widgets/chat/k_voice_input.dart
- ✅ lib/presentation/screens/profile/profile_screen.dart
- ✅ lib/presentation/screens/journal/journal_screen.dart
- ✅ lib/presentation/screens/mood/mood_screen.dart

### Theme Property References
The following files have been updated to use theme_improved.dart:

- ✅ lib/presentation/screens/home/home_screen.dart
- ✅ lib/presentation/screens/home/home_screen_fixed.dart
- ✅ lib/presentation/screens/chat/session_start_screen.dart
- ✅ lib/presentation/screens/chat/chat_screen.dart
- ✅ lib/presentation/widgets/chat/k_invite_modal.dart
- ✅ lib/presentation/widgets/common/k_button.dart
- ✅ lib/presentation/screens/profile/profile_screen.dart
- ✅ lib/presentation/screens/journal/journal_screen.dart
- ✅ lib/presentation/screens/mood/mood_screen.dart

## Remaining Issues to Fix

### Medium Priority

#### 1. Fix Undefined Methods ✅
- ✅ lib/data/remote/database_service.dart - Methods are correctly implemented
- ✅ lib/data/remote/websocket_service.dart - Methods are correctly implemented

#### 2. Fix Type Mismatches ✅
- ✅ lib/domain/providers/scheduling_provider.dart - No type mismatches found

### Low Priority

#### 1. Remove Unused Imports and Variables
- Various files throughout the codebase

## How to Fix Common Issues

### 1. Replacing Iconsax with AppIcons

#### Step 1: Update imports
```dart
// Replace this:
import 'package:iconsax/iconsax.dart';

// With this:
import 'package:kounselme/config/app_icons.dart';
```

#### Step 2: Replace icon references
```dart
// Replace this:
Icon(Iconsax.home)
Icon(Iconsax.home_15)  // Filled version

// With this:
Icon(AppIcons.home)
Icon(AppIcons.filled(AppIcons.home))  // Filled version
```

#### Common Iconsax to AppIcons Mappings:
| Iconsax | AppIcons |
|---------|----------|
| Iconsax.home | AppIcons.home |
| Iconsax.message | AppIcons.chat |
| Iconsax.document | AppIcons.journal |
| Iconsax.emoji_happy | AppIcons.sentiment |
| Iconsax.user | AppIcons.profile |
| Iconsax.notification | AppIcons.bell |
| Iconsax.setting_2 | AppIcons.settings |
| Iconsax.calendar_1 | AppIcons.calendar |
| Iconsax.arrow_right_3 | AppIcons.arrowRight |
| Iconsax.health | AppIcons.heart |
| Iconsax.moon | AppIcons.star |
| Iconsax.close_circle | AppIcons.close |
| Iconsax.add_circle | AppIcons.add |
| Iconsax.tick_circle | AppIcons.success |
| Iconsax.copy | AppIcons.attachment |

### 2. Fixing withOpacity() Usage

#### Option 1: Use predefined light color variants
```dart
// Replace this:
color: AppTheme.electricViolet.withOpacity(0.1)

// With this:
color: AppTheme.heliotropeLight  // Light variant of electricViolet
```

#### Option 2: Use AppTheme.getShadow() for shadows
```dart
// Replace this:
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 4,
    offset: const Offset(0, 2),
  ),
],

// With this:
boxShadow: AppTheme.getShadow(
  elevation: AppTheme.elevationXS,
  shadowColor: AppTheme.codGray,
),
```

#### Option 3: Create helper methods for consistent color handling
```dart
// Helper method to get light color for cards based on the main color
Color _getLightColorForCard(Color color) {
  if (color == AppTheme.electricViolet) {
    return AppTheme.heliotropeLight;
  } else if (color == AppTheme.robinsGreen) {
    return AppTheme.successLight;
  } else if (color == AppTheme.yellowSea) {
    return AppTheme.warningLight;
  } else {
    // Use a default light color for fallback
    return AppTheme.gallery;
  }
}
```

### 3. Updating Theme Property References

#### Step 1: Update imports
```dart
// Replace this:
import 'package:kounselme/config/theme.dart';

// With this:
import 'package:kounselme/config/theme_improved.dart';
```

#### Step 2: Replace theme property references
```dart
// Replace these:
AppTheme.textTheme.titleLarge
AppTheme.primaryColor
AppTheme.surfaceColor
AppTheme.textColor
AppTheme.onPrimaryColor
AppTheme.borderColor
AppTheme.shadowColor
AppTheme.iconColor
AppTheme.textSecondaryColor
AppTheme.successColor

// With these:
Theme.of(context).textTheme.titleLarge  // For text styles
AppTheme.electricViolet  // For primary color
AppTheme.snowWhite  // For surface color
AppTheme.primaryText  // For text color
AppTheme.snowWhite  // For on-primary color
AppTheme.divider  // For border color
AppTheme.codGray  // For shadow color
AppTheme.codGray  // For icon color
AppTheme.secondaryText  // For secondary text color
AppTheme.robinsGreen  // For success color
```

## Next Steps

1. Remove unused imports and variables throughout the codebase
2. Implement real backend connection for chat functionality
3. Enhance session management following the chat user flow
4. Improve error handling and add proper loading states

*This document will be updated as issues are resolved.*
