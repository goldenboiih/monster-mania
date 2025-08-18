import 'package:flutter/material.dart';

class PartSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final Function(String) onChanged;

  const PartSelector({
    Key? key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: '),
        DropdownButton<String>(
          value: selected,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => onChanged(value!),
        ),
      ],
    );
  }
}
