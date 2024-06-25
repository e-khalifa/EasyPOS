import 'package:easy_pos_project/widgets/app_bar/sales_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../widgets/buttons/my_elevated_button.dart';
import '../widgets/cards/my_product_card.dart';
import 'sales_ops.dart';

class SelectingOrderItemsPage extends StatefulWidget {
  String? orderLabel;

  SelectingOrderItemsPage({required this.orderLabel, super.key});

  @override
  State<SelectingOrderItemsPage> createState() =>
      _SelectingOrderItemsPageState();
}

class _SelectingOrderItemsPageState extends State<SelectingOrderItemsPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  Order? order;
  List<Product> products = [];
  List<OrderItem> selectedOrderItems = [];
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
      print('Error in getting products: $e');
    }
    setState(() {});
  }

  // Add a new orderItem to the selected list
  void onAddOrderItem(Product product) {
    try {
      var orderItem = OrderItem();
      orderItem.product = product;
      orderItem.productCount = 0;
      orderItem.productId = product.id;
      selectedOrderItems.add(orderItem);
      setState(() {});
    } catch (e) {
      print('Error in AddOrderItem $e');
    }
  }

  // Get the OrderItem for a given product ID
  OrderItem? getOrderItem(int productId) {
    try {
      if (selectedOrderItems.isNotEmpty) {
        for (var orderItem in selectedOrderItems) {
          if (orderItem.productId == productId) {
            return orderItem;
          }
        }
      } else {
        print('selectedOrderItems is Empty');
      }
    } catch (e) {
      print('Error in gettingOrderItem: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalesAppBar(
        title: (order == null ? 'New Sale' : 'Edit Sale'),
        orderLabel: orderLabel,
        customWidget: TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search For any Product',
            filled: true,
            fillColor: Theme.of(context).secondaryHeaderColor,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
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
                products = data.map((item) => Product.fromJson(item)).toList();
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
      body: products.isEmpty
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
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          //calling MyProductcard
                          return MyProductCard(
                            showCategory: false,
                            imageUrl: product.image,
                            name: product.name,
                            description: product.description,
                            stock: product.stock,
                            price: product.price,
                            //onlyShow widget if the orderItem isn't null, after pressing the + for the first time
                            showWidget: getOrderItem(product.id!) != null &&
                                    getOrderItem(product.id!)!.productCount! > 0
                                ? true
                                : false,

                            rightWidget: Container(
                                child: getOrderItem(product.id!) != null
                                    ? getOrderItem(product.id!)!.productCount! >
                                            0
                                        ? CircleAvatar(
                                            backgroundColor: Colors.green,
                                            radius: 11,
                                            child: Text(
                                                '${getOrderItem(product.id!)!.productCount!}'),
                                          )
                                        : null
                                    : null),
                            //OnpressedWidget
                            rightPressed: () {
                              try {
                                if (getOrderItem(product.id!)!.productCount ==
                                    getOrderItem(product.id!)!.product!.stock)
                                  return;
                                getOrderItem(product.id!)!.productCount =
                                    getOrderItem(product.id!)!.productCount! +
                                        1;
                                setState(() {
                                  print(
                                      'orderItem count ${getOrderItem(product.id!)!.productCount}');
                                });
                              } catch (e) {
                                print('Error in adding orderItem $e');
                              }
                            },
                            rightIcon: Icons.add_circle,
                            rightIconColor: Colors.green,

                            rightIconPressed: () {
                              //Calling onAdd when the user press + for the first time
                              onAddOrderItem(product);
                              try {
                                if (getOrderItem(product.id!)!.productCount ==
                                    getOrderItem(product.id!)!.product!.stock)
                                  return;
                                getOrderItem(product.id!)!.productCount =
                                    getOrderItem(product.id!)!.productCount! +
                                        1;
                                setState(() {
                                  print(
                                      'orderItem count ${getOrderItem(product.id!)!.productCount}');
                                });
                              } catch (e) {
                                print('Error in adding orderItem $e');
                              }
                            },

                            leftIcon: Icons.remove_circle,
                            leftIconColor: Colors.red,
                            leftIconPressed: () async {
                              try {
                                if (getOrderItem(product.id!)!.productCount ==
                                    0) return;
                                getOrderItem(product.id!)!.productCount =
                                    getOrderItem(product.id!)!.productCount! -
                                        1;
                                setState(() {
                                  print(
                                      'orderItem count ${getOrderItem(product.id!)!.productCount}');
                                });
                              } catch (e) {
                                print('Error in removing orderItem $e');
                              }
                            },
                          );
                        }),
                  ),
                  MyElevatedButton(
                      label: 'Continue',
                      onPressed: () {
                        slideRightWidget(
                            newPage: SalesOpsPage(
                                selectedOrderItems: selectedOrderItems),
                            context: context);
                      })
                ],
              ),
            ),
    );
  }
}
