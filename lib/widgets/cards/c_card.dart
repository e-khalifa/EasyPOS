import 'package:flutter/material.dart';

/* USED in: 
          - CategoriesListPage
          - ClientsListPage
*/
class CCard extends StatelessWidget {
  final Future<void> Function() onDeleted;
  final void Function()? onEdit;
  final Widget? customWidget;
  final String? name;
  final String? description;
  final String? phone;
  final String? address;
  final String? email;

  const CCard({
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
      color: Theme.of(context).secondaryHeaderColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(15),
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
                onPressed: onDeleted),
          ),
        ],
      ),
    );
  }
}
