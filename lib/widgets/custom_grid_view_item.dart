import 'package:flutter/material.dart';

class CustomGridViewItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final void Function()? onTap;

  const CustomGridViewItem(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.2),
            radius: 40,
            child: Icon(icon, color: color, size: 45),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          )
        ]),
      ),
    );
  }
}
