import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextInputType type;
  final bool obscure;
  final bool isRequired;
  final Widget? suffix;
  final Widget? prefix;
  final IconData? icon;
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    required this.type,
    this.obscure = false,
    this.isRequired = true,
    this.suffix,
    this.prefix,
    this.icon,
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    this.controller,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color containerBorderColor = Colors.transparent;
    if (_errorText != null) {
      containerBorderColor = Pallete.error;
    } else if (_isFocused) {
      containerBorderColor = Pallete.primary;
    } else {
      containerBorderColor = isDark ? Colors.transparent : const Color(0xFFE8ECE9);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Pallete.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: containerBorderColor,
              width: _isFocused || _errorText != null ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C322E) : const Color(0xFFF0F4F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Pallete.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.label != null) ...[
                      Text(
                        widget.label!,
                        style: AppFonts.font(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Pallete.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscure,
                      keyboardType: widget.type,
                      style: AppFonts.font(fontSize: 14, color: widget.textColor),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: AppFonts.font(fontSize: 14, color: Pallete.textHint),
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                      ),
                      validator: (v) {
                        final err = widget.validator?.call(v) ??
                            (widget.isRequired && (v == null || v.isEmpty) ? 'Required' : null);
                        if (err != _errorText) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _errorText = err;
                            });
                          });
                        }
                        return err;
                      },
                    ),
                  ],
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: 8),
                widget.suffix!,
              ],
            ],
          ),
        ),
        if (_errorText != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
            child: Text(
              _errorText!,
              style: AppFonts.font(
                fontSize: 12,
                color: Pallete.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

