import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/*Used in {
           - ProductListPage
           - SelectingOrderItemPage

}*/
class MyProductCard extends StatelessWidget {
  final String? name;
  final String? description;
  final String? category;
  final double? price;
  final int? stock;
  final String? imageUrl;
  final IconData leftIcon;
  IconData? rightIcon;
  final Color? rightIconColor;
  final Color? leftIconColor;
  var rightWidget;

  bool showCategory = false;
  bool showWidget = false;

  Future<void> Function() leftIconPressed;
  void Function()? rightIconPressed;
  void Function()? rightPressed;

  MyProductCard({
    super.key,
    required this.name,
    required this.description,
    required this.leftIconPressed,
    required this.rightIconPressed,
    this.rightPressed,
    required this.price,
    required this.stock,
    required this.showCategory,
    required this.showWidget,
    required this.leftIcon,
    this.rightWidget,
    this.rightIcon,
    this.rightIconColor,
    required this.leftIconColor,
    this.category,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).secondaryHeaderColor,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),

        //Stack over the card: to add the price bottom right
        child: Stack(children: [
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
                      color: Colors.white,
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

              //Somhow widget didn't have the same position as the icon with the same values
              showWidget
                  ? Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        child: rightWidget,
                        onTap: rightPressed,
                      ))
                  : Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(rightIcon),
                        iconSize: 25,
                        onPressed: rightIconPressed,
                        color: rightIconColor,
                      )),
              Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    icon: Icon(leftIcon),
                    color: leftIconColor,
                    iconSize: 25,
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
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 5),

            showCategory
                ? Text(
                    'Category: $category',
                    style: const TextStyle(fontSize: 12),
                  )
                : const SizedBox(),
            Divider(
              color: Colors.grey.shade300,
            ),
            Text('In Stock: $stock', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
          ]),
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
