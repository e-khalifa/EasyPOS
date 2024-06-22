import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  Future<void> Function() onDeleted;
  void Function()? onEdit;
  final Widget? customWidget; // For customizing elements for each page

  final String? name;
  final String? description;
  final String? phone;
  final String? address;
  final String? email;

  ListCard({
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
      elevation: 8,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),

      // Swipe to delete

      child: Dismissible(
        key: Key(name!),
        onDismissed: (direction) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Confirm Deleting'),
                  content:
                      const Text('Are you sure you want to delete this item?'),
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
                        await onDeleted();

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.black.withOpacity(0.8),
                            content: Text(
                              '$name deleted',
                              textAlign: TextAlign.center,
                            )));
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              });
        },
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(
              name!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: customWidget,
            trailing: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
