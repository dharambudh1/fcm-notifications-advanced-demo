import "package:flutter/material.dart";

class CommonCheckBox extends StatelessWidget {
  const CommonCheckBox({
    required this.iconData,
    required this.value,
    required this.title,
    required this.onChanged,
    super.key,
  });

  final IconData iconData;
  final bool value;
  final String title;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: value,
      secondary: Icon(iconData),
      title: Text(title),
      subtitle: Text("Should have a $title"),
      onChanged: onChanged,
      activeColor: Theme.of(context).buttonTheme.colorScheme!.primary,
    );
  }
}
