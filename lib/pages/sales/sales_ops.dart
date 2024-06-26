import 'package:easy_pos_project/pages/home.dart';
import 'package:easy_pos_project/pages/sales/selecting_order_items.dart';
import 'package:easy_pos_project/widgets/text_field/my_text_field.dart';
import 'package:easy_pos_project/widgets/app_bar/sales_app_bar.dart';
import 'package:easy_pos_project/widgets/tiles/order_items_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/sql_helper.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/product.dart';
import '../../widgets/buttons/my_elevated_button.dart';
import '../../widgets/drop_down/client_drop_down.dart';

//NEED TO- Disply discount and price after

class SalesOpsPage extends StatefulWidget {
  List<OrderItem> selectedOrderItems;
  String? orderLabel;

  final Order? order;

  SalesOpsPage(
      {required this.selectedOrderItems,
      this.order,
      this.orderLabel,
      super.key});

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

  @override
  void initState() {
    try {
      if (widget.order != null) {
        // Setting initial values for editing an existing order
        widget.orderLabel = widget.order!.label!;
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
    widget.orderLabel = widget.order == null
        ? '#OR${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}'
        : widget.order?.label;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SalesAppBar(
        title: (widget.order == null ? 'New Sale' : 'Edit Sale'),
        orderLabel: widget.orderLabel,
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

                            return OrderItemsTile(
                              name: '${orderItem.product!.name}',
                              count: orderItem.productCount,
                              price: orderItem.product!.price,
                              imageUrl: orderItem.product!.image,
                            );
                          }),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            fixedSize: const Size(double.maxFinite, 50),
                            padding: const EdgeInsets.all(20),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.grey.shade700),
                        child: Text(
                          'Add Product',
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey.shade600),
                        ),
                        onPressed: () {
                          slideRightWidget(
                              newPage: SelectingOrderItemsPage(
                                  orderLabel: widget.orderLabel),
                              context: context);
                        },
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$calculateOrginalPrice EGP',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              MyTextField(
                showHint: true,
                label: 'Add Comment',
                controller: commentController,
              ),
              const SizedBox(height: 20),
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
          const SnackBar(
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
          'label': widget.orderLabel,
          'orginalPrice': orginalPrice,
          'discount': double.tryParse(discountController.text) ??
              0, // Handle empty field
          'discountedPrice': discountedPrice,
          'comment': commentController.text,
          'clientId': selectedClientId
        });

        var batch = sqlHelper.db!.batch();
        for (var orderItem in widget.selectedOrderItems) {
          batch.insert('orderItems', {
            'orderId': orderId,
            'productId': orderItem.productId,
            'productCount': orderItem.productCount,
          });
        }
        var result = await batch.commit();

        // Print the order table
        var orderTable = await sqlHelper.db!.query('orders');
        print('Order Table:');
        for (var row in orderTable) {
          print(
              'Order ID: ${row['id']}, Label: ${row['label']}, Original Price: ${row['orginalPrice']}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Order Created Successfully',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
        slideRightWidget(newPage: const HomePage(), context: context);
      } else {
        // Update an existing order
        await sqlHelper.db!.update(
          'orders',
          {
            'label': widget.orderLabel,
            'orginalPrice': orginalPrice,
            'discount': double.tryParse(discountController.text) ??
                0, // Handle empty field
            'discountedPrice': discountedPrice,
            'comment': commentController.text,
            'clientId': selectedClientId
          },
          where: 'id =?',
          whereArgs: [widget.order?.id],
        );
        var batch = sqlHelper.db!.batch();
        for (var orderItem in widget.selectedOrderItems) {
          batch.update('orderItems', {
            'orderId': orderItem.orderId,
            'productId': orderItem.productId,
            'productCount': orderItem.productCount,
          });
        }
        var result = await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Changes saved!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        slideRightWidget(newPage: const HomePage(), context: context);
      }
    } catch (e) {
      print('Error in adding order : $e');
    }
  }

  double? get calculateOrginalPrice {
    for (var orderItem in widget.selectedOrderItems) {
      orginalPrice = orginalPrice +
          (orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0);
    }
    return orginalPrice;
  }
}
