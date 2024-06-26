import 'package:flutter/material.dart';

/* Used in: 
           - HomePage
           */
class HeaderCard extends StatelessWidget {
  final String label;
  final String value;
  final void Function()? onTap;

  const HeaderCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: const Color.fromARGB(255, 32, 109, 225),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color.fromARGB(255, 220, 252, 255),
                  fontSize: 16,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color.fromARGB(255, 152, 196, 253),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
