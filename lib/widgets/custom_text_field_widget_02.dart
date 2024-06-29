import 'package:flutter/material.dart';

class CustomTextFieldWidget02 extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool obscureText;
  final Color hoverBorderColor;
  final Color focusedBorderColor;
  final Color defaultBorderColor;
  final Widget? prefixIcon;
  final TextStyle? labelStyle;
  final Color? labelColor;
  final TextEditingController controller;

  const CustomTextFieldWidget02({
    Key? key,
    required this.labelText,
    this.hintText,
    this.validator,
    this.onSaved,
    this.obscureText = false,
    this.hoverBorderColor = Colors.green,
    this.focusedBorderColor = Colors.green,
    this.defaultBorderColor = Colors.grey,
    this.prefixIcon,
    this.labelStyle,
    this.labelColor, // Add this line
    required this.controller,
  }) : super(key: key);

  @override
  _CustomTextFieldWidget02State createState() =>
      _CustomTextFieldWidget02State();
}

class _CustomTextFieldWidget02State extends State<CustomTextFieldWidget02> {
  final FocusNode _focusNode = FocusNode();
  bool _isPressed = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  void _handleTextChange() {
    setState(() {});
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        validator: widget.validator,
        onSaved: widget.onSaved,
        obscureText: _obscureText,
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: widget.labelText,
              style: TextStyle(
                fontSize: 16.0,
                color: widget.labelColor ?? Theme.of(context).textTheme.bodyMedium!.color, 
              ),
              children: const <TextSpan>[
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red, fontSize: 16.0),
                ),
              ],
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 1.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 1.0,
            ),
          ),
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _isPressed
                  ? widget.hoverBorderColor
                  : widget.defaultBorderColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.focusedBorderColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: widget.controller.text.isNotEmpty && widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    size: 18,
                  ),
                  onPressed: _toggleObscureText,
                )
              : null,
          prefixIcon: widget.prefixIcon,
        ),
      ),
    );
  }
}
