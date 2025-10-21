// lib/widgets/custom_textfield.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? textInputType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textInputType,
    this.isPassword = false,
    this.validator,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputType,
      obscureText: _obscure,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0x801E5255),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : null,
      ),
    );
  }
}
