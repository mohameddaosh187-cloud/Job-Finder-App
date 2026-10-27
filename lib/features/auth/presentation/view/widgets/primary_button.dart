import 'package:flutter/material.dart';
import 'package:job_finder/core/routes/theme/locale_controller.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 54,
  });

  static const Color blue = Color(0xFF385CF2);

  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isArabic = _isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: blue.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white70,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null && isArabic) ...[
                Icon(
                  icon,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (icon != null && !isArabic) ...[
                const SizedBox(width: 10),
                Icon(
                  icon,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
