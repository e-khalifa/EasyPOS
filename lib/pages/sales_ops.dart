import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_pos_project/pages/selecting_order_items.dart';
import 'package:easy_pos_project/widgets/text_field/my_text_field.dart';
import 'package:easy_pos_project/widgets/app_bar/sales_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../widgets/buttons/my_elevated_button.dart';
import '../widgets/drop_down/client_drop_down.dart';

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
  var orginalPrice = 0.0;
  var discountedPrice = 0.0;

  var formKey = GlobalKey<FormState>();
  final discountController = TextEditingController();
  final commentController = TextEditingController();
  TextEditingController clientDropdownSearchController =
      TextEditingController();
  int? selectedClientId;

  List<Product>? products;
  String? orderLabel;

  @override
  void initState() {
    try {
      if (widget.order != null) {
        // Setting initial values for editing an existing order
        orderLabel = widget.order!.label!;
        commentController.text = widget.order!.comment!;
        discountController.text = '${widget.order?.discount ?? ''}';
        orginalPrice = widget.order!.orginalPrice!;
        discountedPrice = widget.order!.discountedPrice!;
        selectedClientId = widget.order?.clientId;
      }
    } catch (e) {
      // Handle the error
      print('An error occurredi in edditing product: $e');
    }
    initPage();
    super.initState();
  }

  void initPage() {
    final DateTime now = DateTime.now();
    orderLabel = widget.order == null
        ? '#OR${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}'
        : widget.order?.label;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalesAppBar(
        title: (widget.order == null ? 'New Sale' : 'Edit Sale'),
        orderLabel: orderLabel,
        customWidget: ClientsDropDown(
            selectedValue: selectedClientId,
            onChanged: (value) {
              selectedClientId = value;
              setState(() {});
            },
            clientSearchController: clientDropdownSearchController),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                color: Theme.of(context).secondaryHeaderColor,
                surfaceTintColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.selectedOrderItems.length,
                          itemBuilder: (context, index) {
                            final orderItem = widget.selectedOrderItems[index];
                            print('orderItem: ${orderItem.product!.name}');

                            return ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  height: 70,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  imageUrl: orderItem.product!.image ?? '',
                                  //Error placeholder
                                  errorWidget: (context, url, error) =>
                                      Container(
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
                                '${orderItem.product!.name}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${orderItem.product!.price} EGP',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              trailing: Container(
                                height: 30,
                                width: 30,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '${orderItem.productCount}x',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                      SizedBox(height: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.all(20),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.grey.shade700),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                            ),
                            Text(
                              'Add Product',
                            )
                          ],
                        ),
                        onPressed: () {
                          slideRightWidget(
                              newPage: SelectingOrderItemsPage(
                                  orderLabel: orderLabel),
                              context: context);
                        },
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${calculateOrginalPrice} EGP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              /*  if (discountController != null)
                                Text('- ${discountController.text}'),
                              Text(
                                  '${calculateTotalPrice! - double.parse(discountController.text)} EGP')*/
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 10),
                      MyTextField(
                        showHint: true,
                        label: 'Add Discount',
                        controller: discountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              MyTextField(
                showHint: true,
                label: 'Add Comment',
                controller: commentController,
              ),
              SizedBox(height: 20),
              MyElevatedButton(
                  label: 'Confirm',
                  color: Colors.green,
                  onPressed: () async {
                    await onSetOrder();
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      if ((widget.selectedOrderItems.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'You Must Add Order Items First',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }
      if (widget.order == null) {
        // Add a new order
        var orderId = await sqlHelper.db!
            .insert('orders', conflictAlgorithm: ConflictAlgorithm.replace, {
          'label': orderLabel,
          'orginalPrice': orginalPrice,
          'discount': double.parse(discountController.text),
          'discountedPrice': discountedPrice,
          'comment': commentController.text,
          'clientId': selectedClientId
        });

        var batch = sqlHelper.db!.batch();
        for (var orderItem in widget.selectedOrderItems) {
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
      }
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

  double? get calculateOrginalPrice {
    for (var orderItem in widget.selectedOrderItems) {
      orginalPrice = orginalPrice +
          (orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0);
    }
    return orginalPrice;
  }

  double? get calculateDiscountedPrice {
    for (var orderItem in widget.selectedOrderItems) {
      if (discountController.text != null) {
        discountedPrice =
            orginalPrice - (double.parse(discountController.text) ?? 0);
      }
    }
    return discountedPrice;
  }
}
