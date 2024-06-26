import 'package:easy_pos_project/widgets/app_bar/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../widgets/cards/custom_grid_view_item.dart';
import '../widgets/cards/header_card.dart';
import 'categories/categories_list.dart';
import 'clients/clients_list.dart';
import 'exchange_rate.dart';
import 'products/products_list.dart';
import 'sales/sales_ops.dart';
import 'sales/all_sales.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();
  List<Order> orders = [];
  var sales = 0.0;

  @override
  void initState() {
    getOrders();
    super.initState();
  }

  Future<void> getOrders() async {
    try {
      var data = await sqlHelper.db!.rawQuery("""
       SELECT * FROM orders
    """);
      if (data.isNotEmpty) {
        orders = data.map((item) => Order.fromJson(item)).toList();
      } else {
        orders = [];
      }
      // Print the retrieved orders for debugging
    } catch (e) {
      print('Error in getting orders: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
              color: Theme.of(context).primaryColor,
              height: MediaQuery.of(context).size.height / 3,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Text(
                            'Easy POS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ]),

                        const SizedBox(height: 20),
                        //Calling headercard #2
                        HeaderCard(
                          label: 'Exchange Rate',
                          value: '1 EUR = 51.88 Egp',
                          onTap: () async {
                            slideRightWidget(
                                newPage: const ExchangeRateTable(),
                                context: context);
                          },
                        ),

                        const SizedBox(height: 10),

                        HeaderCard(
                            label: 'Today\'s Sales',
                            value: '$calculateSales Egp',
                            onTap: () {
                              slideRightWidget(
                                  newPage: const AllSalesPage(),
                                  context: context);
                            }),
                      ]))),

          //gridview container
          Expanded(
              child: Container(
            color: Theme.of(context).secondaryHeaderColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                crossAxisCount: 2,
                children: [
                  CustomGridViewItem(
                    label: 'Sales Statistics',
                    icon: Icons.calculate,
                    color: Colors.orange,
                    onTap: () {
                      slideRightWidget(
                          newPage: const AllSalesPage(), context: context);
                    },
                  ),
                  CustomGridViewItem(
                    label: 'Products',
                    icon: Icons.inventory_2,
                    color: Colors.pink,
                    onTap: () {
                      slideRightWidget(
                          newPage: const ProductsListPage(), context: context);
                    },
                  ),
                  CustomGridViewItem(
                      label: 'Clients',
                      icon: Icons.groups,
                      color: Colors.lightBlue,
                      onTap: () {
                        slideRightWidget(
                            newPage: const ClientsListPage(), context: context);
                      }),
                  CustomGridViewItem(
                    label: 'New sale',
                    icon: Icons.point_of_sale,
                    color: Colors.green,
                    onTap: () {
                      slideRightWidget(
                          newPage: SalesOpsPage(
                            selectedOrderItems: [],
                          ),
                          context: context);
                    },
                  ),
                  CustomGridViewItem(
                    label: 'Categories',
                    icon: Icons.category,
                    color: Colors.yellow,
                    onTap: () {
                      slideRightWidget(
                          newPage: const CategoriesListPage(),
                          context: context);
                    },
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  // Calculate Sales
  double? get calculateSales {
    for (var order in orders) {
      sales = sales + (order.orginalPrice ?? 0);
    }
    return sales;
  }
}
