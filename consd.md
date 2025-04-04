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
- ✅ lib/presentation/screens/settings/settings_screen.dart

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
- ✅ lib/presentation/widgets/chat/k_time_limit_notification.dart
- ✅ lib/presentation/widgets/chat/k_participant_list.dart
- ✅ lib/presentation/widgets/chat/k_chat_history_drawer.dart
- ✅ lib/presentation/widgets/chat/k_session_timer.dart
- ✅ lib/presentation/widgets/chat/k_time_purchase_dialog.dart
- ✅ lib/presentation/widgets/chat/k_session_start_dialog.dart
- ✅ lib/config/theme_improved.dart

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
- ✅ lib/presentation/screens/settings/settings_screen.dart
- ✅ lib/presentation/widgets/chat/k_chat_scheduling.dart
- ✅ lib/presentation/widgets/chat/k_quick_actions_bar.dart
- ✅ lib/presentation/widgets/chat/k_time_limit_notification.dart
- ✅ lib/presentation/widgets/chat/k_participant_list.dart
- ✅ lib/presentation/widgets/chat/k_chat_history_drawer.dart
- ✅ lib/presentation/widgets/chat/k_session_timer.dart
- ✅ lib/presentation/widgets/chat/k_time_purchase_dialog.dart
- ✅ lib/presentation/widgets/chat/k_session_start_dialog.dart
- ✅ lib/presentation/widgets/common/k_app_bar.dart
- ✅ lib/presentation/widgets/common/k_bottom_nav.dart
- ✅ lib/presentation/widgets/common/k_card.dart
- ✅ lib/presentation/widgets/common/k_text_field.dart
- ✅ lib/presentation/widgets/home/quick_action_item.dart
- ✅ lib/presentation/screens/auth/login_screen.dart
- ✅ lib/presentation/screens/auth/signup_screen.dart
- ✅ lib/presentation/screens/auth/forgot_password_screen.dart
- ✅ lib/presentation/screens/onboarding/onboarding_screen.dart
- ✅ lib/presentation/screens/chat/session_dialogs.dart

### Theme Consolidation
The following theme-related improvements have been made:

- ✅ Removed duplicate theme.dart file and consolidated all theme properties in theme_improved.dart
- ✅ Updated all imports across the codebase to use theme_improved.dart
- ✅ Fixed method name references (modernCardDecoration → cardDecoration, modernButtonStyle → primaryButtonStyle)
- ✅ Fixed parameter names in method calls (color → backgroundColor)

## Fixed Code Issues ✅

### High Priority

#### 1. Fix Database Connection Issues ✅
- ✅ lib/data/remote/database_service.dart - Fixed PostgreSQLConnection.fromUri method issue

#### 2. Fix WebSocket Service ✅
- ✅ lib/data/remote/websocket_service.dart - Added missing _setupMockWebSocket method

#### 3. Fix Scheduling Provider ✅
- ✅ lib/domain/providers/scheduling_provider.dart - Fixed DateTime to TZDateTime conversion issues

### Medium Priority

#### 1. Fix Undefined Methods ✅
- ✅ lib/data/remote/database_service.dart - Methods are correctly implemented
- ✅ lib/data/remote/websocket_service.dart - Methods are correctly implemented

#### 2. Fix Type Mismatches ✅
- ✅ lib/domain/providers/scheduling_provider.dart - Fixed type mismatches

#### 3. Fix Unused Variables ✅
- ✅ lib/data/remote/database_service.dart - Removed unused _uuid field
- ✅ lib/domain/providers/scheduling_provider.dart - Fixed unused chat variable

### Low Priority

#### 1. Remove Unused Imports and Variables
- ✅ lib/data/remote/database_service.dart - Removed unused uuid import
- Various other files throughout the codebase

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

#### Option 2: Use withValues() for custom opacity
```dart
// Replace this:
color: Colors.black.withOpacity(0.05)

// With this:
color: Colors.black.withValues(alpha: 0.05)
```

#### Option 3: Use AppTheme.getShadow() for shadows
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

1. Remove remaining unused imports and variables throughout the codebase
2. Implement real backend connection for chat functionality
3. Enhance session management following the chat user flow
4. Improve error handling and add proper loading states

*This document will be updated as issues are resolved.*


[{
	"resource": "/C:/Users/hpspecter/kounselme/lib/presentation/widgets/chat/k_participant_list_fixed.dart",
	"owner": "_generated_diagnostic_collection_name_#4",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 59,
	"startColumn": 49,
	"endLineNumber": 59,
	"endColumn": 60,
	"tags": [
		2
	]
},{
	"resource": "/C:/Users/hpspecter/kounselme/lib/presentation/widgets/chat/k_participant_list_fixed.dart",
	"owner": "_generated_diagnostic_collection_name_#4",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 80,
	"startColumn": 52,
	"endLineNumber": 80,
	"endColumn": 63,
	"tags": [
		2
	]
},{
	"resource": "/C:/Users/hpspecter/kounselme/lib/presentation/widgets/chat/k_participant_list_fixed.dart",
	"owner": "_generated_diagnostic_collection_name_#4",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 166,
	"startColumn": 40,
	"endLineNumber": 166,
	"endColumn": 51,
	"tags": [
		2
	]
},{
	"resource": "/C:/Users/hpspecter/kounselme/lib/presentation/widgets/chat/k_participant_list_fixed.dart",
	"owner": "_generated_diagnostic_collection_name_#4",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 167,
	"startColumn": 43,
	"endLineNumber": 167,
	"endColumn": 54,
	"tags": [
		2
	]
},{
	"resource": "/C:/Users/hpspecter/kounselme/lib/presentation/widgets/chat/k_thinking_indicator.dart",
	"owner": "_generated_diagnostic_collection_name_#4",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 105,
	"startColumn": 62,
	"endLineNumber": 105,
	"endColumn": 73,
	"tags": [
		2
	]
},{
	"resource": "/C:/Users/hpspecter/kounselme/lib/presentation/widgets/chat/k_typing_indicator.dart",
	"owner": "_generated_diagnostic_collection_name_#4",
	"code": {
		"value": "deprecated_member_use",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/deprecated_member_use",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 2,
	"message": "'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.\nTry replacing the use of the deprecated member with the replacement.",
	"source": "dart",
	"startLineNumber": 55,
	"startColumn": 41,
	"endLineNumber": 55,
	"endColumn": 52,
	"tags": [
		2
	]
}]