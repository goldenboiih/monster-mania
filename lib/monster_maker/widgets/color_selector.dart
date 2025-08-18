import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final String label;
  final Color currentColor;
  final Function(Color) onColorChanged;
  final List<Color> colors;
  final double labelWidth;

  const ColorSelector({
    super.key,
    required this.label,
    required this.currentColor,
    required this.onColorChanged,
    required this.colors,

    this.labelWidth = 100, // You can adjust this globally
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(label),
        ),
        ...colors.map((color) {
          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: color == currentColor ? Colors.black : Colors.grey,
                  width: color == currentColor ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ],
    );
  }
}
