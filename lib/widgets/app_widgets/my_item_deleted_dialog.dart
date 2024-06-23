import 'package:flutter/material.dart';

class MyItemDeletedDialog extends StatelessWidget {
  Future<void> Function() onDeleteditem;
  String? item;

  MyItemDeletedDialog(
      {required this.item, required this.onDeleteditem, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Confirm Deleting'),
      content: const Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await onDeleteditem();

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.black.withOpacity(0.8),
                content: Text(
                  '$item deleted',
                  textAlign: TextAlign.center,
                )));
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
