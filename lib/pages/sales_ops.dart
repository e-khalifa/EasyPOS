import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../widgets/client_drop_down.dart';

class SalesOpsPage extends StatefulWidget {
  final Order? order;
  const SalesOpsPage({this.order, super.key});

  @override
  State<SalesOpsPage> createState() => _SalesOpsPageState();
}

class _SalesOpsPageState extends State<SalesOpsPage> {
  int? selectedClientId;
  TextEditingController clientDropdownSearchController =
      TextEditingController();

  List<Product>? products;
  List<OrderItem>? selectedOrderItems;
  String? orderLabel;

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
        Select P.*,C.name as categoryName from products P
        Inner JOIN categories C
        On P.categoryId = C.id
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

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    getProducts();
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
                  ClientsDropDown(
                      selectedValue: selectedClientId,
                      onChanged: (value) {
                        selectedClientId = value;
                        setState(() {});
                      },
                      clientSearchController: clientDropdownSearchController),
                ]))));
  }
}
