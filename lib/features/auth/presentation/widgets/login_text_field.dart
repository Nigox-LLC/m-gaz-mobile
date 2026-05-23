import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.enabled = true,
    this.hasError = false,
    this.errorText,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.onClear,
    this.onToggleObscure,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool enabled;
  final bool hasError;
  final String? errorText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onToggleObscure;

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  static const _textStrong = Color(0xFF202020);
  static const _textSub = Color(0xFFBBBBBB);
  static const _fieldBackground = Color(0xFFF0F0F0);
  static const _strokeSoft = Color(0xFFE8E8E8);
  static const _focusStroke = Color(0xFF335CFF);
  static const _errorStroke = Color(0xFFF45725);
  static const _errorText = Color(0xFFDD4C1E);

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant LoginTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleFocusChanged() => setState(() {});

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Color get _borderColor {
    if (widget.hasError) {
      return _errorStroke;
    }
    if (_focusNode.hasFocus) {
      return _focusStroke;
    }
    return _strokeSoft;
  }

  double get _borderWidth => _focusNode.hasFocus && !widget.hasError ? 2 : 1;

  List<BoxShadow> get _boxShadow {
    if (widget.hasError) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ];
    }

    if (_focusNode.hasFocus) {
      return const [];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.10),
        blurRadius: 3,
        offset: const Offset(0, 2),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: _textStrong,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 56,
          decoration: BoxDecoration(
            color: _fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: _borderWidth),
            boxShadow: _boxShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.obscureText,
                  cursorColor: _focusStroke,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  autocorrect: false,
                  enableSuggestions: widget.onToggleObscure == null,
                  style: GoogleFonts.manrope(
                    color: _textStrong,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 24 / 15,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.manrope(
                      color: _textSub,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 24 / 15,
                    ),
                    contentPadding: const EdgeInsets.only(left: 16, right: 8),
                  ),
                ),
              ),
              if (hasText && widget.enabled && widget.onClear != null)
                _FieldIconButton(icon: Icons.close, onPressed: widget.onClear!),
              if (hasText && widget.enabled && widget.onToggleObscure != null)
                _FieldIconButton(
                  icon: widget.obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onPressed: widget.onToggleObscure!,
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: _errorText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldIconButton extends StatelessWidget {
  const _FieldIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 48,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 48),
        splashRadius: 18,
        icon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
