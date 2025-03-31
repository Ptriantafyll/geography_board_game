import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.onSelectColor,
  });

  final Function(int index) onSelectColor;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  int _selectedIndex = 0;

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
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: ToggleButtons(
        isSelected: List.generate(
            _availableColors.length, (index) => index == _selectedIndex),
        constraints: BoxConstraints(
          maxWidth: 40,
          maxHeight: 40,
        ),
        selectedColor: Colors.white,
        fillColor: _availableColors[_selectedIndex],
        splashColor: Colors.white,
        borderRadius: BorderRadius.circular(20),
        borderColor: Colors.black,
        selectedBorderColor: Colors.black,
        onPressed: (int index) {
          selectColor(index);
        },
        children: List.generate(_availableColors.length, (index) {
          return Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: _availableColors[index],
              border: Border.all(
                color:
                    _selectedIndex == index ? Colors.black : Colors.transparent,
                width: 3,
              ),
              borderRadius: createBorders(_availableColors, index),
            ),
          );
        }),
      ),
    );
  }
}
