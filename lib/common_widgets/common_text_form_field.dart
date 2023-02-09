import "package:flutter/material.dart";

class CommonTextFormField extends StatelessWidget {
  const CommonTextFormField({
    required this.onChanged,
    required this.label,
    super.key,
  });

  final void Function(String)? onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        label: Text(label),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return "Please fill the $label";
        }
        return null;
      },
    );
  }
}
