import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/color_constants.dart';
import '../../di/injection_container.dart';
import '../../services/currency_service.dart';

/// Merkezi form alanı widget'ı
/// Tüm form alanları için tutarlı görünüm sağlar.
class AppFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final Color? accentColor;
  final AutovalidateMode? autovalidateMode;

  const AppFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.initialValue,
    this.accentColor,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? ColorConstants.kirmiziVurgu;

    return TextFormField(
      autovalidateMode: autovalidateMode,
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        floatingLabelStyle: TextStyle(color: color),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
      ),
    );
  }

  /// Para tutarı girişi için hazır yapılandırma
  static AppFormField amount({
    Key? key,
    required TextEditingController controller,
    String? labelText,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    Color? accentColor,
  }) {
    return AppFormField(
      key: key,
      controller: controller,
      labelText:
          labelText ?? 'Tutar (${getIt<CurrencyService>().currentSymbol})',
      prefixIcon: Icon(
        Icons.attach_money,
        color: accentColor ?? ColorConstants.kirmiziVurgu,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
      validator: validator,
      onChanged: onChanged,
      accentColor: accentColor,
    );
  }

  /// Açıklama/İsim girişi için hazır yapılandırma
  static AppFormField description({
    Key? key,
    required TextEditingController controller,
    String labelText = 'Açıklama',
    String? Function(String?)? validator,
    Function(String)? onChanged,
    Color? accentColor,
  }) {
    return AppFormField(
      key: key,
      controller: controller,
      labelText: labelText,
      prefixIcon: Icon(
        Icons.description,
        color: accentColor ?? ColorConstants.kirmiziVurgu,
      ),
      validator: validator,
      onChanged: onChanged,
      accentColor: accentColor,
    );
  }
}
