import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.onSelectColor,
    required this.availableColors,
  });

  final Function(int index) onSelectColor;
  final List<Color> availableColors;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int selectedIndex = 0;

  BorderRadius? createBorders(List<Color> colors, index) {
    if (index == colors.length - 1) {
      return BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }

    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      );
    }

    return null;
  }

  selectColor(int index) {
    widget.onSelectColor(index);

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: ToggleButtons(
        isSelected: List.generate(
            widget.availableColors.length, (index) => index == selectedIndex),
        constraints: BoxConstraints(
          maxWidth: 40,
          maxHeight: 40,
        ),
        selectedColor: Colors.white,
        fillColor: widget.availableColors[selectedIndex],
        splashColor: Colors.white,
        borderRadius: BorderRadius.circular(20),
        borderColor: Colors.black,
        selectedBorderColor: Colors.black,
        onPressed: (int index) {
          selectColor(index);
        },
        children: List.generate(widget.availableColors.length, (index) {
          return Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: widget.availableColors[index],
              border: Border.all(
                color:
                    selectedIndex == index ? Colors.black : Colors.transparent,
                width: 3,
              ),
              borderRadius: createBorders(widget.availableColors, index),
            ),
          );
        }),
      ),
    );
  }
}
