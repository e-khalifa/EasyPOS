import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../helpers/sql_helper.dart';
import '../../models/order.dart';
import '../../widgets/cards/my_order_card.dart';
import '../../widgets/dialog/my_item_deleted_dialog.dart';
import 'sales_ops.dart';

/*NEED TO- - Show orderItems on Edit mode
           - 1- Enable drop down
             2- filter the dates(add date in sales table, or by the label)
             3- diplay the matched orders with the overall sales     

*/
class AllSalesPage extends StatefulWidget {
  const AllSalesPage({super.key});

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();
  List<Order> orders = [];
  var sales = 0.0;
  bool enabled = false;
  var period = ['Today', 'Last Week', 'Last Month', 'Last Year', 'All Time'];

  String? selectedPeriod = 'Today';

  @override
  void initState() {
    getOrders();
    super.initState();
  }

  /* The Inner join query turns data: [] with noe errors!
   SELECT O.*, C.name as clientName FROM orders O
       INNER JOIN clients C
       ON O.clientId = C.id */

  Future<void> getOrders() async {
    try {
      var data = await sqlHelper.db!.rawQuery("""
       SELECT * FROM orders
    """);
      print('Raw query result: $data');

      if (data.isNotEmpty) {
        orders = data.map((item) => Order.fromJson(item)).toList();
      } else {
        orders = [];
      }

      // Print the retrieved orders for debugging
      print('Retrieved orders: $orders');
    } catch (e) {
      print('Error in getting orders: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ALL Sales'),
        ),
        body: orders.isEmpty
            ? const Center(child: Text('No Orders Found'))
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  DropdownButtonFormField(
                    disabledHint: Text('$selectedPeriod'),
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(left: 25, right: 11),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            width: 2, color: Theme.of(context).primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    isExpanded: true,
                    items: period.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: enabled
                        ? (String? newValue) {
                            setState(() {
                              selectedPeriod = newValue;
                            });
                          }
                        : null,
                    value: selectedPeriod, // Set the value to the selected item
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            print('Product: ${order.label}');

                            return OrderCard(
                              onDeleted: () => onDeleteOrder(order),
                              onEdit: () {
                                slideRightWidget(
                                    newPage: SalesOpsPage(
                                      selectedOrderItems: [],
                                      order: order,
                                    ),
                                    context: context);
                              },
                              orderLabel: order.label,
                              clientName: order.clientName,
                              orginalPrice: order.orginalPrice,
                              discount: order.discount,
                              discountedPrice: order.discountedPrice,
                            );
                          }))
                ]),
              ));
  }

  //Deleting order
  Future<void> onDeleteOrder(Order order) {
    //Callling itemDeleted dialog
    return showDialog(
        context: context,
        builder: (context) {
          return MyItemDeletedDialog(
              item: order.label,
              onDeleteditem: () async {
                await sqlHelper.db!
                    .delete('orders', where: 'id =?', whereArgs: [order.id]);
                getOrders();
              });
        });
  }
}
