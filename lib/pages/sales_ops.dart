import 'package:easy_pos_project/pages/adding_products.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../widgets/app_widgets/my_elevated_button.dart';
import '../widgets/client_drop_down.dart';

class SalesOpsPage extends StatefulWidget {
  final Order? order;
  const SalesOpsPage({this.order, super.key});

  @override
  State<SalesOpsPage> createState() => _SalesOpsPageState();
}

class _SalesOpsPageState extends State<SalesOpsPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  int? selectedClientId;
  TextEditingController clientDropdownSearchController =
      TextEditingController();
  List<Product>? products;
  List<OrderItem>? selectedOrderItems;
  String? orderLabel;

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    orderLabel = widget.order == null
        ? '#OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.label;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'New Sale' : 'Edit Sale'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: const Color.fromARGB(255, 250, 250, 250),
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Label : $orderLabel',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ClientsDropDown(
                            selectedValue: selectedClientId,
                            onChanged: (value) {
                              selectedClientId = value;
                              setState(() {});
                            },
                            clientSearchController:
                                clientDropdownSearchController),
                        const SizedBox(
                          height: 20,
                        ),
                        OutlinedButton(
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                                BorderSide(color: Colors.grey)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.grey.shade700),
                            overlayColor:
                                MaterialStateProperty.all(Colors.grey.shade200),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                              ),
                              Text('Add Products',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.0,
                                  ))
                            ],
                          ),
                          onPressed: () {
                            slideRightWidget(
                                newPage: SelectingOrderItemsPage(),
                                context: context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 250, 250, 250),
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text('Order Items',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                            )),
                        for (var orderItem in selectedOrderItems ?? [])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading:
                                  Image.network(orderItem.product.image ?? ''),
                              title: Text(
                                  '${orderItem.product.name ?? 'No name'},${orderItem.productCount}X'),
                              trailing: Text('${orderItem.product.price}'),
                            ),
                          ),
                        Container(
                          color: Colors.red,
                          child: Text('TODO : add discount textfield'),
                        ),
                        Text(
                          'Total Price:${calculateTotalPrice}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                MyElevatedButton(
                    label: 'Add Order',
                    onPressed: () async {
                      await onSetOrder();
                    })
              ],
            ),
          )),
    );
  }

  Future<void> onSetOrder() async {
    try {
      if (selectedOrderItems == null ||
          (selectedOrderItems?.isEmpty ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'You Must Add Order Items First',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      var sqlHelper = GetIt.I.get<SqlHelper>();

      // Create a batch operation for inserting order items
      var orderId = await sqlHelper.db!
          .insert('orders', conflictAlgorithm: ConflictAlgorithm.replace, {
        'label': orderLabel,
        'totalPrice': calculateTotalPrice,
        'discount': 0,
        'clientId': selectedClientId
      });

      var batch = sqlHelper.db!.batch();
      for (var orderItem in selectedOrderItems!) {
        batch.insert('orderProductItems', {
          'orderId': orderId,
          'productId': orderItem.productId,
          'productCount': orderItem.productCount,
        });
      }
      var result = await batch.commit();

      print('>>>>>>>> orderProductItems${result}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Order Created Successfully',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error : $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  double? get calculateTotalPrice {
    var totalPrice = 0.0;
    for (var orderItem in selectedOrderItems ?? []) {
      totalPrice = totalPrice +
          (orderItem?.productCount ?? 0) * (orderItem?.product?.price ?? 0);
    }
    return totalPrice;
  }
}
