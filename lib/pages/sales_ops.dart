import 'package:dotted_border/dotted_border.dart';
import 'package:easy_pos_project/pages/adding_products.dart';
import 'package:easy_pos_project/widgets/app_widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../widgets/app_widgets/my_elevated_button.dart';
import '../widgets/client_drop_down.dart';

//layout issues
class SalesOpsPage extends StatefulWidget {
  List<OrderItem> selectedOrderItems;
  final Order? order;

  SalesOpsPage({required this.selectedOrderItems, this.order, super.key});

  @override
  State<SalesOpsPage> createState() => _SalesOpsPageState();
}

class _SalesOpsPageState extends State<SalesOpsPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  var formKey = GlobalKey<FormState>();
  final discountController = TextEditingController();
  int? selectedClientId;
  TextEditingController clientDropdownSearchController =
      TextEditingController();
  List<Product>? products;
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
      body: Column(
        children: [
          Container(
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              alignment: Alignment.centerLeft,
              color: const Color(0xFFFFF2CC),
              child: Text('${orderLabel}')),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClientsDropDown(
                      selectedValue: selectedClientId,
                      onChanged: (value) {
                        selectedClientId = value;
                        setState(() {});
                      },
                      clientSearchController: clientDropdownSearchController),
                  SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      color: const Color.fromARGB(255, 250, 250, 250),
                      surfaceTintColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Expanded(
                                child: ListView.builder(
                                    itemCount: widget.selectedOrderItems.length,
                                    itemBuilder: (context, index) {
                                      final orderItem =
                                          widget.selectedOrderItems[index];
                                      print(
                                          'orderItem: ${orderItem.product!.name}');

                                      return ListTile(
                                        leading: Image.network(
                                            orderItem.product!.image ?? ''),
                                        title:
                                            Text('${orderItem.product!.name}'),
                                        subtitle:
                                            Text('${orderItem.product!.price}'),
                                        trailing: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                              '${orderItem.productCount}x'),
                                        ),
                                      );
                                    })),
                            SizedBox(height: 20),
                            Expanded(
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  side: MaterialStateProperty.all(
                                      BorderSide(color: Colors.grey)),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  foregroundColor: MaterialStateProperty.all(
                                      Colors.grey.shade700),
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.grey.shade200),
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
                            ),
                            SizedBox(height: 20),
                            DottedBorder(child: Divider()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${calculateTotalPrice}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                DottedBorder(child: Divider()),
                                MyTextField(
                                  label: 'Add discount',
                                  controller: discountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  MyElevatedButton(
                      label: 'Confirm',
                      onPressed: () async {
                        await onSetOrder();
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      if (widget.selectedOrderItems == null ||
          (widget.selectedOrderItems?.isEmpty ?? false)) {
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
      for (var orderItem in widget.selectedOrderItems!) {
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
    for (var orderItem in widget.selectedOrderItems ?? []) {
      totalPrice = totalPrice +
          (orderItem?.productCount ?? 0) * (orderItem?.product?.price ?? 0);
    }
    return totalPrice;
  }
}
