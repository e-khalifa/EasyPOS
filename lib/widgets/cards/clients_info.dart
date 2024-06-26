import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

/* Used in : 
           -ClientsListPage 
           */
class ClientsInfo extends StatelessWidget {
  IconData icon;
  String? label;
  double width;
  ClientsInfo(
      {required this.width,
      required this.label,
      required this.icon,
      super.key});

  @override
  Widget build(BuildContext context) {
    return label != ''
        ? Row(
            children: [
              Icon(icon, size: 25, color: Colors.grey),
              const SizedBox(width: 10),
              SizedBox(
                  width: width,
                  child: DottedBorder(
                      padding: const EdgeInsets.all(5),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      strokeWidth: .5,
                      child: Text(
                        '$label',
                        style: const TextStyle(fontSize: 14),
                      )))
            ],
          )
        : SizedBox();
  }
}
