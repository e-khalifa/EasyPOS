import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/* Used In: 
           - SalesOpsPage
           */

class OrderItemsTile extends StatelessWidget {
  final String? name;
  final int? count;
  final double? price;
  final String? imageUrl;

  const OrderItemsTile(
      {required this.name,
      required this.count,
      required this.price,
      this.imageUrl,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            height: 70,
            width: 50,
            fit: BoxFit.cover,
            imageUrl: imageUrl ?? '',
            //Error placeholder
            errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.error,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          name!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$price EGP',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        trailing: Container(
          height: 30,
          width: 30,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '${count}x',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
