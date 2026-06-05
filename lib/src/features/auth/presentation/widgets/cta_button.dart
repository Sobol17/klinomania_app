import 'package:flutter/material.dart';

enum CTAButtonVariant { filled, outline }

class CTAButton extends StatelessWidget {
  const CTAButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = CTAButtonVariant.filled,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CTAButtonVariant variant;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool enabled = onPressed != null && !isLoading;
    final bool filled = variant == CTAButtonVariant.filled;
    final Color background;
    final Color textColor;
    final BorderSide border;

    if (filled) {
      background = enabled ? theme.colorScheme.primary : Colors.white;
      textColor = enabled ? Colors.white : const Color(0xFF9EA4B4);
      border = BorderSide(
        color: enabled ? Colors.transparent : const Color(0xFFE3E8F0),
      );
    } else {
      background = Colors.white;
      textColor = theme.colorScheme.primary;
      border = BorderSide(color: theme.colorScheme.primary, width: 1.5);
    }

    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled || variant == CTAButtonVariant.outline ? 1 : 0.8,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.fromBorderSide(border),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 2,
                  ),
                )
              : content,
        ),
      ),
    );
  }
}
