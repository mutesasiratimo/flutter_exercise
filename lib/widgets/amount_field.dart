import 'package:flutter/material.dart';

class AmountField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const AmountField({super.key, required this.controller, required this.label});

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(labelText: widget.label),
      keyboardType: TextInputType.numberWithOptions(),
    );
  }
}
