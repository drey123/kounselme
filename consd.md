Launching lib/chat_test_app.dart on Chrome in debug mode...
lib/config/theme_improved.dart:314:57: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
    final color = shadowColor ?? Colors.black.withAlpha(0.2);
                                                        ^
lib/config/theme_improved.dart:320:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            color: color.withAlpha(0.05),
                                   ^
lib/config/theme_improved.dart:328:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            color: color.withAlpha(0.1),
                                   ^
lib/config/theme_improved.dart:336:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            color: color.withAlpha(0.1),
                                   ^
lib/config/theme_improved.dart:344:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            color: color.withAlpha(0.1),
                                   ^
lib/config/theme_improved.dart:352:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            color: color.withAlpha(0.1),
                                   ^
lib/config/theme_improved.dart:360:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            color: color.withAlpha(0.11),
                                   ^
lib/config/theme_improved.dart:368:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            color: color.withAlpha(0.1),
                                   ^
lib/config/theme_improved.dart:406:62: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
        shadowColor: shadowColor ?? electricViolet.withAlpha(0.08),
                                                             ^
lib/config/theme_improved.dart:432:60: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
        shadowColor: shadowColor ?? colors.first.withAlpha(0.3),
                                                           ^
lib/config/theme_improved.dart:445:34: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
      color: baseColor.withAlpha(opacity),
                                 ^
lib/config/theme_improved.dart:448:36: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
        color: baseColor.withAlpha(borderOpacity),
                                   ^
lib/config/theme_improved.dart:507:60: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
          WidgetStateProperty.all(electricViolet.withAlpha(0.3)),
                                                           ^
lib/config/theme_improved.dart:543:40: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            return baseColor.withAlpha(0.05);
                                       ^
lib/config/theme_improved.dart:546:40: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            return baseColor.withAlpha(0.03);
                                       ^
lib/config/theme_improved.dart:647:40: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            return baseColor.withAlpha(0.1);
                                       ^
lib/config/theme_improved.dart:650:40: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            return baseColor.withAlpha(0.05);
                                       ^
lib/config/theme_improved.dart:682:40: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            return baseColor.withAlpha(0.1);
                                       ^
lib/config/theme_improved.dart:685:40: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
            return baseColor.withAlpha(0.05);
                                       ^
lib/config/theme_improved.dart:857:47: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
        shadowColor: electricViolet.withAlpha(0.08),
                                              ^
lib/config/theme_improved.dart:911:49: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
        selectedColor: electricViolet.withAlpha(0.2),
                                                ^
lib/config/theme_improved.dart:967:46: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
                  return snowWhite.withAlpha(0.15);
                                             ^
lib/domain/providers/chat_provider.dart:144:44: Error: The getter 'userId' isn't defined for the class 'ChatParticipant'.
 - 'ChatParticipant' is from 'package:kounselme/domain/models/chat_participant.dart' ('lib/domain/models/chat_participant.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'userId'.
        .where((p) => typingIds.contains(p.userId))
                                           ^^^^^^
lib/domain/providers/chat_provider.dart:193:45: Error: The getter 'typingStream' isn't defined for the class 'WebSocketService'.
 - 'WebSocketService' is from 'package:kounselme/data/remote/websocket_service.dart' ('lib/data/remote/websocket_service.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'typingStream'.
    _typingSubscription = _webSocketService.typingStream.listen(_handleTypingIndicator);
                                            ^^^^^^^^^^^^
lib/domain/providers/chat_provider.dart:196:50: Error: The getter 'participantStream' isn't defined for the class 'WebSocketService'.
 - 'WebSocketService' is from 'package:kounselme/data/remote/websocket_service.dart' ('lib/data/remote/websocket_service.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'participantStream'.
    _participantSubscription = _webSocketService.participantStream.listen(_handleParticipantUpdate);
                                                 ^^^^^^^^^^^^^^^^^
lib/domain/providers/chat_provider.dart:199:44: Error: The getter 'errorStream' isn't defined for the class 'WebSocketService'.
 - 'WebSocketService' is from 'package:kounselme/data/remote/websocket_service.dart' ('lib/data/remote/websocket_service.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'errorStream'.
    _errorSubscription = _webSocketService.errorStream.listen(_handleWebSocketError);
                                           ^^^^^^^^^^^
lib/domain/providers/chat_provider.dart:225:9: Error: No named parameter with the name 'isHost'.
        isHost: state.sessionId != null,
        ^^^^^^
lib/domain/providers/chat_provider.dart:315:51: Error: Member not found: 'error'.
      connectionError: status == ConnectionStatus.error,
                                                  ^^^^^
lib/domain/providers/chat_provider.dart:567:39: Error: Required named parameter 'userId' must be provided.
      await _sessionService.endSession(
                                      ^
lib/domain/providers/chat_provider.dart:631:23: Error: The method 'inviteUser' isn't defined for the class 'WebSocketService'.
 - 'WebSocketService' is from 'package:kounselme/data/remote/websocket_service.dart' ('lib/data/remote/websocket_service.dart').
Try correcting the name to the name of an existing method, or defining a method named 'inviteUser'.
    _webSocketService.inviteUser(email, message: message);
                      ^^^^^^^^^^
lib/domain/providers/chat_provider.dart:641:23: Error: The method 'removeUser' isn't defined for the class 'WebSocketService'.
 - 'WebSocketService' is from 'package:kounselme/data/remote/websocket_service.dart' ('lib/data/remote/websocket_service.dart').
Try correcting the name to the name of an existing method, or defining a method named 'removeUser'.
    _webSocketService.removeUser(userId);
                      ^^^^^^^^^^
lib/presentation/widgets/chat/k_chat_input.dart:247:74: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
                          shadowColor: AppTheme.electricViolet.withAlpha(0.08),
                                                                         ^
lib/presentation/widgets/chat/k_chat_input.dart:311:75: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
                              shadowColor: AppTheme.robinsGreen.withAlpha(0.3),
                                                                          ^
lib/presentation/widgets/chat/k_chat_input.dart:326:78: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
                              shadowColor: AppTheme.electricViolet.withAlpha(0.3),
                                                                             ^
lib/presentation/widgets/chat/k_chat_input.dart:391:56: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
              color: AppTheme.electricViolet.withAlpha(0.05),
                                                       ^
lib/presentation/widgets/chat/k_chat_input.dart:394:58: Error: The argument type 'double' can't be assigned to the parameter type 'int'.
                color: AppTheme.electricViolet.withAlpha(0.1),
                                                         ^
lib/presentation/widgets/chat/k_session_start_dialog.dart:230:51: Error: Member not found: 'yellowSea'.
                        backgroundColor: AppTheme.yellowSea,
                                                  ^^^^^^^^^
lib/presentation/widgets/chat/k_time_display.dart:46:25: Error: Member not found: 'yellowSea'.
        return AppTheme.yellowSea;
                        ^^^^^^^^^
lib/presentation/widgets/chat/k_time_display.dart:57:27: Error: Member not found: 'yellowSeaLight'.
          return AppTheme.yellowSeaLight;
                          ^^^^^^^^^^^^^^
lib/presentation/widgets/chat/k_time_display.dart:151:35: Error: Member not found: 'yellowSeaLight'.
                  color: AppTheme.yellowSeaLight,
                                  ^^^^^^^^^^^^^^
lib/presentation/widgets/chat/k_time_display.dart:157:37: Error: Member not found: 'yellowSea'.
                    color: AppTheme.yellowSea,
                                    ^^^^^^^^^
lib/presentation/widgets/chat/k_time_limit_notification.dart:38:43: Error: Member not found: 'yellowSea'.
          color: isApproaching ? AppTheme.yellowSea : AppTheme.error,
                                          ^^^^^^^^^
lib/presentation/widgets/chat/k_time_limit_notification.dart:47:49: Error: Member not found: 'yellowSea'.
                color: isApproaching ? AppTheme.yellowSea : AppTheme.error,
                                                ^^^^^^^^^
lib/presentation/widgets/chat/k_time_limit_notification.dart:61:52: Error: Member not found: 'yellowSea'.
                          isApproaching ? AppTheme.yellowSea : AppTheme.error,
                                                   ^^^^^^^^^
lib/data/remote/session_service.dart:15:34: Error: Member not found: 'backendUrl'.
  final String _baseUrl = '${Env.backendUrl}/api/v1';
                                 ^^^^^^^^^^
lib/presentation/widgets/common/k_button.dart:45:47: Error: Member not found: 'successLight'.
            disabledBackgroundColor: AppTheme.successLight,
                                              ^^^^^^^^^^^^
lib/presentation/widgets/common/k_button.dart:56:39: Error: Member not found: 'yellowSea'.
            backgroundColor: AppTheme.yellowSea,
                                      ^^^^^^^^^
lib/presentation/widgets/common/k_button.dart:58:47: Error: Member not found: 'warningLight'.
            disabledBackgroundColor: AppTheme.warningLight,
                                              ^^^^^^^^^^^^
Waiting for connection from debug service on Chrome...             62.0s
Failed to compile application.
PS C:\Users\hpspecter\kounselme> 