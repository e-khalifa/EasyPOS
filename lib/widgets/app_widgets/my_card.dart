import 'package:flutter/material.dart';

import 'my_item_deleted_dialog.dart';

class MyCard extends StatelessWidget {
  final Future<void> Function() onDeleted;
  final void Function()? onEdit;
  final Widget? customWidget;
  final String? name;
  final String? description;
  final String? phone;
  final String? address;
  final String? email;

  MyCard({
    required this.onDeleted,
    required this.onEdit,
    required this.customWidget,
    required this.name,
    this.description,
    this.phone,
    this.address,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 250, 250, 250),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(15),
                title: Text(
                  name!,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                subtitle: customWidget,
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyItemDeletedDialog(
                      item: name,
                      onDeleteditem: onDeleted,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
