import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_pos_project/widgets/app_widgets/my_item_deleted_dialog.dart';
import 'package:flutter/material.dart';

/*Used in {
           - ProductListPage
           - SelectingOrderItemPage

}*/
class ProductGridViewItem extends StatelessWidget {
  final String? name;
  final String? description;
  final String? category;
  final double? price;
  final int? stock;
  final String? imageUrl;
  final IconData leftIcon;
  final IconData righticon;
  final Color? rightIconColor;
  final Color? leftIconColor;

  bool showCategory = false;

  Future<void> Function() leftIconPressed;
  void Function()? rightIconPressed;

  ProductGridViewItem({
    super.key,
    required this.name,
    required this.description,
    required this.leftIconPressed,
    required this.rightIconPressed,
    required this.price,
    required this.stock,
    required this.showCategory,
    required this.leftIcon,
    required this.righticon,
    required this.rightIconColor,
    required this.leftIconColor,
    this.category,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 250, 250, 250),
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),

        //Stack over the card: to add the price bottom right
        child: Stack(children: [
          Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //Stack over the image: to add icons top
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl: imageUrl ?? '',

                    //Error placeholder
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.error,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(righticon),
                      onPressed: rightIconPressed,
                      color: rightIconColor,
                    )),
                Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: Icon(leftIcon),
                      color: leftIconColor,
                      onPressed: leftIconPressed,
                    )),
              ]),
              const SizedBox(
                height: 10,
              ),
              Text(
                name!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description!,
                style: const TextStyle(fontSize: 13),
              ),
              SizedBox(height: 5),

              showCategory
                  ? Text(
                      'Category: $category',
                      style: const TextStyle(fontSize: 12),
                    )
                  : SizedBox(),
              const Divider(
                color: Colors.grey,
              ),
              Text('In Stock: $stock', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 10),
            ]),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              '$price EGP',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }
}
