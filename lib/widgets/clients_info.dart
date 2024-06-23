import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

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
        ? Container(
            child: Row(
              children: [
                Icon(icon, size: 25, color: Colors.grey),
                SizedBox(width: 10),
                Container(
                    width: width,
                    child: DottedBorder(
                        padding: EdgeInsets.all(5),
                        borderType: BorderType.RRect,
                        radius: Radius.circular(5),
                        strokeWidth: .5,
                        child: Text(
                          '$label',
                          style: TextStyle(fontSize: 14),
                        )))
              ],
            ),
          )
        : SizedBox();
  }
}
