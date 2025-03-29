import 'package:example/core/validators/validators.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    required this.onChanged,
    this.initialValue,
    this.label,
    this.suffixIcon,
    this.obscureText = false,
    this.required = false,
    this.focusNode,
    this.onHoverChanged,
    this.validators,
    this.maxWidth,
    super.key,
  });

  final String? label;
  final String? initialValue;
  final void Function(String) onChanged;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool required;
  final FocusNode? focusNode;
  final void Function(bool)? onHoverChanged;
  final List<FormFieldValidator<String>>? validators;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              required ? '$label *' : label!,
              style: const TextStyle(fontSize: 18),
            ),
            const Gap.x(5),
          ],
          MouseRegion(
            onEnter:
                onHoverChanged != null ? (e) => onHoverChanged!(true) : null,
            onExit:
                onHoverChanged != null ? (e) => onHoverChanged!(false) : null,
            child: TextFormField(
              initialValue: initialValue,
              focusNode: focusNode,
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onChanged: onChanged,
              obscureText: obscureText,
              validator: _validator(context),
            ),
          ),
        ],
      ),
    );
  }

  String? Function(String?)? _validator(BuildContext context) {
    if (!required && validators == null) return null;
    return (String? value) {
      return _validate([Validators.required], value);
    };
  }

  String? _validate(
    List<FormFieldValidator<String>> validators,
    String? value,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
