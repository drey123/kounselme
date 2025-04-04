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

class _KChatInputState extends State<KChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _showQuickActions = false;

  // Animation controller for quick actions
  late AnimationController _animationController;
  late Animation<double> _quickActionsHeightAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateHasText);
    _focusNode.addListener(_handleFocusChange);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _quickActionsHeightAnimation = Tween<double>(
      begin: 0,
      end: 60,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.removeListener(_updateHasText);
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
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

  void _handleFocusChange() {
    // Auto-hide quick actions when input gets focus
    if (_focusNode.hasFocus && _showQuickActions) {
      _toggleQuickActions();
    }
  }

  void _toggleQuickActions() {
    setState(() {
      _showQuickActions = !_showQuickActions;

      if (_showQuickActions) {
        _animationController.forward();
        // Remove focus from text field when showing quick actions
        _focusNode.unfocus();
      } else {
        _animationController.reverse();
        // Focus on text field when hiding quick actions
        _focusNode.requestFocus();
      }
    });
  }

  void _handleSend() {
    if (_controller.text.isNotEmpty &&
        !widget.isLoading &&
        !widget.isDisabled) {
      widget.onSendMessage(_controller.text);
      _controller.clear();

      // Keep focus on the input field after sending
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive adjustments
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLandscape = screenWidth > screenHeight;

    // Adjust sizes based on screen dimensions
    final double iconSize = isSmallScreen ? 20 : 24;
    final double buttonSize = isSmallScreen ? 40 : 48;
    final double horizontalPadding = isSmallScreen ? 8 : 16;
    final double verticalPadding = isSmallScreen ? 6 : 8;

    return Column(
      children: [
        // Quick action bar (visible when toggled)
        AnimatedBuilder(
          animation: _quickActionsHeightAnimation,
          builder: (context, child) {
            return Container(
              height: _quickActionsHeightAnimation.value,
              decoration: BoxDecoration(
                color: AppTheme.snowWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
              ),
              child: _quickActionsHeightAnimation.value > 0
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Row(
                        children: [
                          if (widget.onInviteUser != null)
                            _buildQuickActionButton(
                              icon: AppIcons.addUser,
                              label: 'Invite',
                              onTap: widget.onInviteUser,
                              isSmallScreen: isSmallScreen,
                            ),
                          if (widget.onStartTimer != null)
                            _buildQuickActionButton(
                              icon: AppIcons.timer,
                              label: 'Timer',
                              onTap: widget.onStartTimer,
                              isSmallScreen: isSmallScreen,
                            ),
                          if (widget.onShareLink != null)
                            _buildQuickActionButton(
                              icon: AppIcons.link,
                              label: 'Share',
                              onTap: widget.onShareLink,
                              isSmallScreen: isSmallScreen,
                            ),
                          if (widget.onUpload != null)
                            _buildQuickActionButton(
                              icon: AppIcons.upload,
                              label: 'Upload',
                              onTap: widget.onUpload,
                              isSmallScreen: isSmallScreen,
                            ),
                          if (widget.onReminder != null)
                            _buildQuickActionButton(
                              icon: AppIcons.clock,
                              label: 'Remind',
                              onTap: widget.onReminder,
                              isSmallScreen: isSmallScreen,
                            ),
                        ],
                      ),
                    )
                  : null,
            );
          },
        ),

        // Main input bar with improved responsiveness
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            color: AppTheme.snowWhite,
            boxShadow: AppTheme.getShadow(
              elevation: AppTheme.elevationS,
            ),
          ),
          child: Row(
            children: [
              // Quick actions toggle with responsive sizing
              IconButton(
                onPressed: (widget.isLoading || widget.isDisabled)
                    ? null
                    : _toggleQuickActions,
                icon: Icon(
                  _showQuickActions ? AppIcons.close : AppIcons.addCircle,
                  color: widget.isDisabled
                      ? AppTheme.divider
                      : AppTheme.electricViolet,
                  size: iconSize,
                ),
                padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                constraints: BoxConstraints(
                    minWidth: isSmallScreen ? 32 : 40,
                    minHeight: isSmallScreen ? 32 : 40),
              ),

              // Text input field with dynamic constraints
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.snowWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _controller.text.isNotEmpty
                              ? AppTheme.heliotrope
                              : AppTheme.divider,
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.getShadow(
                          elevation: 1,
                          shadowColor: AppTheme.electricViolet
                              .withAlpha((0.08 * 255).toInt()),
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !widget.isLoading && !widget.isDisabled,
                        decoration: InputDecoration(
                          hintText: widget.isDisabled
                              ? 'Session ended'
                              : isSmallScreen
                                  ? 'Type message...'
                                  : Strings.typeYourMessage,
                          hintStyle: TextStyle(
                            color: AppTheme.secondaryText,
                            fontFamily: AppTheme.fontInter,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        minLines: 1,
                        maxLines: isLandscape ? 2 : (isSmallScreen ? 3 : 5),
                        style: TextStyle(
                          fontFamily: AppTheme.fontInter,
                          fontSize: isSmallScreen ? 12 : 14,
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Voice/Send button with responsive sizing
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: buttonSize,
                height: buttonSize,
                decoration: widget.isDisabled
                    ? BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(buttonSize / 2),
                      )
                    : _hasText
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.robinsGreen,
                                AppTheme.robinsGreenLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(buttonSize / 2),
                            boxShadow: AppTheme.getShadow(
                              elevation: AppTheme.elevationS,
                              shadowColor: AppTheme.robinsGreen
                                  .withAlpha((0.3 * 255).toInt()),
                            ),
                          )
                        : BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.electricViolet,
                                AppTheme.electricVioletLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(buttonSize / 2),
                            boxShadow: AppTheme.getShadow(
                              elevation: AppTheme.elevationS,
                              shadowColor: AppTheme.electricViolet
                                  .withAlpha((0.3 * 255).toInt()),
                            ),
                          ),
                child: widget.isLoading
                    ? Center(
                        child: SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: isSmallScreen ? 1.5 : 2,
                            color: AppTheme.snowWhite,
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.isDisabled
                              ? null
                              : _hasText
                                  ? _handleSend
                                  : widget.onVoiceInput,
                          borderRadius: BorderRadius.circular(buttonSize / 2),
                          child: Center(
                            child: Icon(
                              _hasText ? AppIcons.send : AppIcons.microphone,
                              color: widget.isDisabled
                                  ? AppTheme.secondaryText
                                  : AppTheme.snowWhite,
                              size: iconSize,
                            ),
                          ),
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
    bool isSmallScreen = false,
  }) {
    final double iconSize = isSmallScreen ? 16 : 20;
    final double fontSize = isSmallScreen ? 10 : 12;
    final double padding = isSmallScreen ? 8 : 12;

    return Padding(
      padding: EdgeInsets.only(right: isSmallScreen ? 8 : 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: padding, vertical: isSmallScreen ? 4 : 8),
            decoration: BoxDecoration(
              color: AppTheme.electricViolet.withAlpha((0.05 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.electricViolet.withAlpha((0.1 * 255).toInt()),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color: AppTheme.heliotropeLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      color: AppTheme.electricViolet, size: iconSize),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.fontInter,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.electricViolet,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
