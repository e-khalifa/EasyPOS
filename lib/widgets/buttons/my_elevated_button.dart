import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final String label;
  final Function() onPressed;
  Color color;
  MyElevatedButton(
      {required this.label,
      required this.onPressed,
      this.color = const Color.fromARGB(255, 0, 87, 218),
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(double.maxFinite, 50),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ));
  }
}
