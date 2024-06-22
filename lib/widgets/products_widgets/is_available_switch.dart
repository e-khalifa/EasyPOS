import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(5),
        color: Colors.transparent,
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.only(right: 5, left: 12, bottom: 9, top: 9),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Is Product Available?'),
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
