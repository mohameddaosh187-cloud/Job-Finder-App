import 'package:flutter/material.dart';
import 'package:job_finder/core/routes/theme/locale_controller.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final bool autocorrect;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.onToggleVisibility,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.autocorrect = true,
  });

  static const Color blue = Color(0xFF385CF2);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final labelColor = colors.onSurface;
    final hintColor = colors.onSurfaceVariant;
    final iconColor = colors.onSurfaceVariant;
    final borderColor = theme.dividerColor;

    final fieldColor = isDark
        ? const Color(0xFF202633)
        : Colors.white;

    OutlineInputBorder buildBorder({
      required Color color,
      double width = 1,
    }) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            textAlign: _isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            onFieldSubmitted: widget.onFieldSubmitted,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            autocorrect: widget.autocorrect,
            textDirection:
                widget.keyboardType == TextInputType.emailAddress
                    ? TextDirection.ltr
                    : (_isArabic ? TextDirection.rtl : TextDirection.ltr),
            textAlign: widget.keyboardType == TextInputType.emailAddress
                ? TextAlign.left
                : (_isArabic ? TextAlign.right : TextAlign.left),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14,
            ),
            cursorColor: AuthTextField.blue,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: iconColor,
                size: 21,
              ),
              suffixIcon: widget.onToggleVisibility == null
                  ? null
                  : IconButton(
                      onPressed: widget.onToggleVisibility,
                      tooltip: _isArabic
                          ? (widget.obscureText
                              ? 'إظهار كلمة المرور'
                              : 'إخفاء كلمة المرور')
                          : (widget.obscureText
                              ? 'Show password'
                              : 'Hide password'),
                      icon: Icon(
                        widget.obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: iconColor,
                      ),
                    ),
              filled: true,
              fillColor: fieldColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: buildBorder(color: borderColor),
              enabledBorder: buildBorder(color: borderColor),
              focusedBorder: buildBorder(
                color: AuthTextField.blue,
                width: 1.5,
              ),
              errorBorder: buildBorder(color: colors.error),
              focusedErrorBorder: buildBorder(
                color: colors.error,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
