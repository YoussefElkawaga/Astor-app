import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum ButtonVariant { primary, secondary, destructive, outline, ghost }

class Button extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Size? size;

  const Button({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getForegroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: variant == ButtonVariant.outline
              ? BorderSide(color: ShadTheme.border)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return ShadTheme.primary;
      case ButtonVariant.secondary:
        return ShadTheme.secondary;
      case ButtonVariant.destructive:
        return ShadTheme.destructive;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return ShadTheme.primaryForeground;
      case ButtonVariant.secondary:
        return ShadTheme.secondaryForeground;
      case ButtonVariant.destructive:
        return ShadTheme.destructiveForeground;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return ShadTheme.foreground;
    }
  }
}
