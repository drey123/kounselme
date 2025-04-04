// lib/presentation/widgets/common/k_app_bar.dart
import 'package:flutter/material.dart';
import 'package:kounselme/config/app_icons.dart';
import 'package:kounselme/config/theme_improved.dart';

class KAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final double? elevation;
  final bool centerTitle;

  const KAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.onBackPressed,
    this.leading,
    this.elevation,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? AppTheme.snowWhite,
                  ),
                ),
                const SizedBox(width: 8),
                titleWidget!,
              ],
            )
          : Text(
              title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor ?? AppTheme.snowWhite,
              ),
            ),
      backgroundColor: backgroundColor ?? AppTheme.electricViolet,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                AppIcons.back,
                color: textColor ?? AppTheme.snowWhite,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
