import 'package:flutter/material.dart';

class AppSearchField extends StatefulWidget {
  String label;
  final ValueChanged<String> onSearchTextChanged;

  AppSearchField(
      {required this.onSearchTextChanged, required this.label, super.key});

  @override
  _AppSearchFieldState createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
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
