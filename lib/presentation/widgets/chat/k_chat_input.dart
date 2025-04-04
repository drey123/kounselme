// lib/presentation/widgets/chat/k_chat_input.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/core/constants/string_constants.dart';

class KChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onInviteUser;
  final VoidCallback? onStartTimer;
  final VoidCallback? onVoiceInput;
  final VoidCallback? onShareLink;
  final VoidCallback? onUpload;
  final VoidCallback? onReminder;

  const KChatInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.isDisabled = false,
    this.onInviteUser,
    this.onStartTimer,
    this.onVoiceInput,
    this.onShareLink,
    this.onUpload,
    this.onReminder,
  });

  @override
  State<KChatInput> createState() => _KChatInputState();
}

class _KChatInputState extends State<KChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _showQuickActions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateHasText);
    _controller.dispose();
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (_controller.text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick action bar (visible when toggled)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showQuickActions ? 60 : 0,
          decoration: BoxDecoration(
            color: AppTheme.snowWhite,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.divider,
                width: 1,
              ),
            ),
          ),
          child: _showQuickActions
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildQuickActionButton(
                        icon: AppIcons.addUser,
                        label: 'Invite',
                        onTap: widget.onInviteUser,
                      ),
                      _buildQuickActionButton(
                        icon: AppIcons.timer,
                        label: 'Timer',
                        onTap: widget.onStartTimer,
                      ),
                      _buildQuickActionButton(
                        icon: AppIcons.link,
                        label: 'Share',
                        onTap: widget.onShareLink,
                      ),
                      _buildQuickActionButton(
                        icon: AppIcons.upload,
                        label: 'Upload',
                        onTap: widget.onUpload,
                      ),
                      _buildQuickActionButton(
                        icon: AppIcons.clock,
                        label: 'Remind',
                        onTap: widget.onReminder,
                      ),
                    ],
                  ),
                )
              : null,
        ),

        // Main input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.snowWhite,
            boxShadow: AppTheme.getShadow(
              elevation: AppTheme.elevationS,
            ),
          ),
          child: Row(
            children: [
              // Quick actions toggle
              IconButton(
                onPressed: (widget.isLoading || widget.isDisabled)
                    ? null
                    : () {
                        setState(() {
                          _showQuickActions = !_showQuickActions;
                        });
                      },
                icon: Icon(
                  _showQuickActions ? AppIcons.close : AppIcons.addCircle,
                  color: widget.isDisabled
                      ? AppTheme.divider
                      : AppTheme.electricViolet,
                ),
              ),

              // Text input field
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Adjust padding based on available width
                    final horizontalPadding =
                        constraints.maxWidth < 300 ? 8.0 : 16.0;

                    return Container(
                      decoration: AppTheme.cardDecoration(
                        backgroundColor: AppTheme.snowWhite,
                        borderRadius: 24,
                        elevation: 1,
                        borderColor: _controller.text.isNotEmpty
                            ? AppTheme.heliotrope
                            : AppTheme.divider,
                      ),
                      child: TextField(
                        controller: _controller,
                        enabled: !widget.isLoading && !widget.isDisabled,
                        decoration: InputDecoration(
                          hintText: widget.isDisabled
                              ? 'Session ended. Cannot send messages.'
                              : Strings.typeYourMessage,
                          hintStyle: TextStyle(
                            color: AppTheme.secondaryText,
                            fontFamily: 'Inter',
                            fontSize: MediaQuery.of(context).size.width < 360
                                ? 14
                                : 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        minLines: 1,
                        maxLines: 5,
                        style: TextStyle(
                          fontFamily: AppTheme.fontInter,
                          fontSize:
                              MediaQuery.of(context).size.width < 360 ? 14 : 16,
                          height: AppTheme.lineHeightNormal,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Voice/Send button (changes based on text input and loading state)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: widget.isDisabled
                    ? BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(24),
                      )
                    : _hasText
                        ? AppTheme.gradientDecoration(
                            colors: [
                              AppTheme.robinsGreen,
                              AppTheme.robinsGreenLight,
                            ],
                            borderRadius: 24,
                          )
                        : AppTheme.gradientDecoration(
                            colors: [
                              AppTheme.electricViolet,
                              AppTheme.electricVioletLight,
                            ],
                            borderRadius: 24,
                          ),
                // Add subtle shadow for depth
                foregroundDecoration: widget.isDisabled
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.getShadow(
                          elevation: AppTheme.elevationS,
                          shadowColor: _hasText
                              ? AppTheme.robinsGreen
                              : AppTheme.electricViolet,
                        ),
                      ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.snowWhite,
                        ),
                      )
                    : IconButton(
                        onPressed: widget.isDisabled
                            ? null
                            : _hasText
                                ? _handleSend
                                : widget.onVoiceInput,
                        icon: Icon(
                          _hasText ? AppIcons.send : AppIcons.microphone,
                          color: widget.isDisabled
                              ? AppTheme.secondaryText
                              : AppTheme.snowWhite,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: AppTheme.glassDecoration(
            baseColor: AppTheme.electricViolet,
            opacity: 0.05,
            borderRadius: 12,
            borderOpacity: 0.1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.heliotropeLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.electricViolet, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.electricViolet,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
