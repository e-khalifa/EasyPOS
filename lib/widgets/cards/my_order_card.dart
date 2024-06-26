import 'package:easy_pos_project/widgets/text_field/my_text_field.dart';
import 'package:flutter/material.dart';

/*Used in {
           - AllSalesPage

}*/
class OrderCard extends StatelessWidget {
  final Future<void> Function() onDeleted;
  final void Function()? onEdit;
  final String? orderLabel;
  final String? clientName;
  final double? orginalPrice;
  final double? discount;
  final double? discountedPrice;
  String? comment;

  OrderCard({
    super.key,
    required this.onDeleted,
    required this.onEdit,
    required this.orderLabel,
    required this.clientName,
    required this.orginalPrice,
    this.discount,
    this.discountedPrice,
    this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderLabel!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: onDeleted),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  color: Colors.grey,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Text(
                  clientName ?? 'Unnamed Client',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            comment == null ? const SizedBox() : MyTextField(label: '$comment'),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Total: $orginalPrice EGP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            /* For displaying discount:
            discount != 0
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      children: [
                        Text('-  $discount'),
                        Text(
                          '$discountedPrice EGP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ))
                : SizedBox(),
                */
          ]),
        ),
      ),
    );
  }
}
