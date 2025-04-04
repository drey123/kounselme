// lib/presentation/widgets/chat/k_invite_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/config/env.dart';
import 'package:kounselme/presentation/widgets/common/k_button.dart';
import 'package:kounselme/presentation/widgets/common/k_text_field.dart';

class KInviteModal extends StatefulWidget {
  final String sessionId;
  final Function(List<String>) onInvite;
  final bool isLoading;

  const KInviteModal({
    super.key,
    required this.sessionId,
    required this.onInvite,
    this.isLoading = false,
  });

  @override
  State<KInviteModal> createState() => _KInviteModalState();
}

class _KInviteModalState extends State<KInviteModal> {
  final TextEditingController _emailController = TextEditingController();
  final List<String> _emails = [];
  final _formKey = GlobalKey<FormState>();
  bool _linkCopied = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _addEmail() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      if (!_emails.contains(email)) {
        setState(() {
          _emails.add(email);
          _emailController.clear();
        });
      }
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _emails.remove(email);
    });
  }

  void _copyInviteLink() {
    // Generate invite link using environment configuration
    final inviteLink = Env.getAppUrl('/join/${widget.sessionId}');
    Clipboard.setData(ClipboardData(text: inviteLink));

    setState(() {
      _linkCopied = true;
    });

    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _linkCopied = false;
        });
      }
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.snowWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invite to Session',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.codGray,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(AppIcons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Invite link section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.heliotropeLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share invite link',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.codGray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.snowWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          Env.getAppUrl('/join/${widget.sessionId}'),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppTheme.codGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    KButton(
                      label: _linkCopied ? 'Copied!' : 'Copy',
                      icon:
                          _linkCopied ? AppIcons.success : AppIcons.attachment,
                      type: KButtonType.primary,
                      onPressed: _copyInviteLink,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Email invite section
          const Text(
            'Invite via email',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.codGray,
            ),
          ),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: KTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addEmail,
                  icon: Icon(AppIcons.add, color: AppTheme.electricViolet),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Email list
          if (_emails.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.snowWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: _emails.map((email) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.chat,
                          size: 16,
                          color: AppTheme.electricViolet,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppTheme.codGray,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeEmail(email),
                          icon: Icon(
                            AppIcons.close,
                            size: 16,
                            color: AppTheme.error,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Send invites button
          SizedBox(
            width: double.infinity,
            child: KButton(
              label: 'Send Invites',
              type: KButtonType.primary,
              isLoading: widget.isLoading,
              fullWidth: true,
              onPressed: _emails.isEmpty
                  ? null
                  : () {
                      widget.onInvite(_emails);
                    },
            ),
          ),
        ],
      ),
    );
  }
}
