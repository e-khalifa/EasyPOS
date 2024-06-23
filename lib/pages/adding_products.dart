import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../widgets/app_widgets/my_elevated_button.dart';
import '../widgets/products_widgets/product_grid_view.dart';

class SelectingOrderItemsPage extends StatefulWidget {
  const SelectingOrderItemsPage({super.key});

  @override
  State<SelectingOrderItemsPage> createState() =>
      _SelectingOrderItemsPageState();
}

class _SelectingOrderItemsPageState extends State<SelectingOrderItemsPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();
  Order? order;

  List<Product> products = [];
  List<OrderItem>? selectedOrderItems;
  String? orderLabel;
  bool notFoundOnSearch = false;

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  //getting available products
  Future<void> getProducts() async {
    try {
      var data = await sqlHelper.db!.rawQuery("""
        Select P.*,C.name as categoryName from products P
        Inner JOIN categories C
        On P.categoryId = C.id
        WHERE P.stock >= 1
      """);

      if (data.isNotEmpty) {
        products = data.map((item) => Product.fromJson(item)).toList();
      } else {
        products = [];
      }
    } catch (e) {
      print('Error in get products: $e');
    }
    setState(() {});
  }

  // Get the OrderItem for a given product ID
  OrderItem? getOrderItem(int productId) {
    try {
      for (var orderItem in selectedOrderItems ?? []) {
        if (orderItem.productId == productId) {
          return orderItem;
        }
      }
      return null;
    } catch (e) {
      print('Error in gettingOrderItem $e');
    }
    return null;
  }

  // Add a new order item to the selected list
  void onAddOrderItem(Product product) {
    var orderItem = OrderItem();
    orderItem.product = product;
    orderItem.productCount = 1;
    orderItem.productId = product.id;
    selectedOrderItems ??= [];
    selectedOrderItems!.add(orderItem);
    setState(() {});
    print('orderItem count ${orderItem.productCount}');
  }

// Remove an order item from the selected list
  void onRemoveOrderItem(int productId) {
    try {
      for (var i = 0; i < (selectedOrderItems?.length ?? 0); i++) {
        if (selectedOrderItems![i].productId == productId) {
          selectedOrderItems!.removeAt(i);
        }
      }
    } catch (e) {
      print('Error in removing orderItem $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(order == null ? 'New Sale' : 'Edit Sale'),

          //Searchbar
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search For any Product',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (text) async {
                  try {
                    if (text.isEmpty) {
                      getProducts();
                      return;
                    }

                    final data = await sqlHelper.db!.rawQuery('''
                      SELECT P.*, C.name as categoryName FROM products P
                      INNER JOIN categories C ON P.categoryId = C.id
                      WHERE (P.name LIKE '%$text%'
                      OR P.description LIKE '%$text%')
                      AND p.stock > 0
                   ''');

                    //if anything related found, map it to a list
                    if (data.isNotEmpty) {
                      products =
                          data.map((item) => Product.fromJson(item)).toList();

                      //nothing found? empty list
                    } else {
                      products = [];
                      notFoundOnSearch = true;
                    }
                  } catch (e) {
                    print('Error in search products: $e');
                  }
                  setState(() {});
                },
              ),
            ),
          )),
      body: products!.isEmpty
          ? notFoundOnSearch
              ? const SizedBox()
              : const Center(
                  child: Text('No Products Found'),
                )
          : Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.86,
                        ),
                        itemCount: products!.length,
                        itemBuilder: (context, index) {
                          final product = products![index];
                          print('Product: ${product.name}');
                          //calling listcard
                          return ProductGridViewItem(
                            showCategory: false,
                            imageUrl: product.image,
                            name: product.name,
                            description: product.description,
                            stock: product.stock,
                            price: product.price,
                            righticon: Icons.add,
                            rightIconColor: Colors.green,
                            rightIconPressed: () {
                              try {
                                //Unexpected Null Value
                                if (getOrderItem(product.id!)!.productCount ==
                                    getOrderItem(product.id!)!.product!.stock)
                                  return;
                                getOrderItem(product.id!)!.productCount =
                                    getOrderItem(product.id!)!.productCount! +
                                        1;

                                setState(() {});
                              } catch (e) {
                                print('Error in adding orderItem $e');
                              }
                            },
                            leftIcon: Icons.remove,
                            leftIconColor: Colors.red,
                            leftIconPressed: () async {
                              if (getOrderItem(product.id!)!.productCount == 0)
                                return;
                              getOrderItem(product.id!)!.productCount =
                                  getOrderItem(product.id!)!.productCount! - 1;
                              setState(() {});
                            },
                          );
                        }),
                  ),
                  MyElevatedButton(
                      label: 'Back',
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              ),
            ),
    );
  }
}
