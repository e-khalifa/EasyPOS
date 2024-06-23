import 'package:flutter/material.dart';

import 'my_item_deleted_dialog.dart';

class MyCard extends StatelessWidget {
  Future<void> Function() onDeleted;
  void Function()? onEdit;
  final Widget? customWidget; // For customizing elements for each page

  final String? name;
  final String? description;
  final String? phone;
  final String? address;
  final String? email;

  MyCard({
    super.key,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ListTile(
          leading: SizedBox(height: 900, width: 0),
          title: Text(
            name!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: customWidget,
          trailing: Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return MyItemDeletedDialog(
                              item: name, onDeleteditem: onDeleted);
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
