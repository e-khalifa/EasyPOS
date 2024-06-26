import 'package:flutter/material.dart';

//Used in : - ProductsOpsPage
class IsAvailableSwitch extends StatefulWidget {
  bool value;
  final void Function(bool?)? onChanged;

  IsAvailableSwitch({super.key, required this.onChanged, required this.value});

  @override
  State<IsAvailableSwitch> createState() => _IsAvailableSwitchState();
}

class _IsAvailableSwitchState extends State<IsAvailableSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.only(right: 5, left: 25, bottom: 4, top: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'Is Product Available?',
          style: TextStyle(
              color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        Switch(
          activeColor: Theme.of(context).primaryColor,
          inactiveTrackColor: Colors.grey.shade300,
          value: widget.value,
          onChanged: (value) {
            setState(() {
              widget.value = value;
              print('Is Product Available? $value');
            });
            widget.onChanged!(value);
          },
        ),
      ]),
    );
  }
}
