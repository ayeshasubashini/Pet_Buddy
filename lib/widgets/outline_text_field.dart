import 'package:flutter/material.dart';
import 'package:pet_buddy/utils/colors.dart';

class OutlineTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool readOnly;
  final String labelText;

  const OutlineTextField({
    super.key,
    required this.textEditingController,
    this.readOnly = false,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: secondaryColor, // Color when the TextField is focused
          ),
        ),
        floatingLabelStyle: const TextStyle(
          color: secondaryColor, // Color of the label text when the TextField is focused
        ),
      ),
    );
  }
}
