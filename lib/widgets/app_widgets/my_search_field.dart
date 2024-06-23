import 'package:flutter/material.dart';

class MySearchField extends StatefulWidget {
  String label;
  final ValueChanged<String> onSearchTextChanged;

  MySearchField(
      {required this.onSearchTextChanged, required this.label, super.key});

  @override
  _MySearchFieldState createState() => _MySearchFieldState();
}

class _MySearchFieldState extends State<MySearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onSearchTextChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        prefixIcon: const Icon(Icons.search),
        hintText: widget.label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
