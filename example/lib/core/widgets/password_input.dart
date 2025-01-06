import 'package:example/core/widgets/text_input.dart';
import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    required this.onChanged,
    this.label,
    this.initialValue,
    super.key,
  });

  final void Function(String) onChanged;
  final String? label;
  final String? initialValue;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool isEmpty = true;
  final focusNode = FocusNode();
  bool obscureText = true;
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    isEmpty = widget.initialValue?.isEmpty ?? true;
    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextInput(
      label: widget.label,
      initialValue: widget.initialValue,
      onChanged: (text) {
        setState(() {
          isEmpty = text.isEmpty;
        });
        widget.onChanged(text);
      },
      obscureText: obscureText,
      suffixIcon: IconButton(
        icon: Visibility(
          visible: _showObscureButton(),
          child: Visibility(
            visible: obscureText,
            replacement: const Icon(Icons.visibility_off, size: 22),
            child: const Icon(Icons.visibility, size: 22),
          ),
        ),
        onPressed: () => setState(() => obscureText = !obscureText),
      ),
      focusNode: focusNode,
      onHoverChanged: (isHovering) {
        setState(() {
          this.isHovering = isHovering;
        });
      },
      required: true,
    );
  }

  bool _showObscureButton() {
    return (focusNode.hasFocus || isHovering) && !isEmpty;
  }
}