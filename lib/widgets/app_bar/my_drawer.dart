import 'package:easy_pos_project/pages/about_app.dart';
import 'package:easy_pos_project/pages/categories/categories_ops.dart';
import 'package:easy_pos_project/pages/sales/sales_ops.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../pages/clients/clients_ops.dart';
import '../../pages/products/products_ops.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Easy POS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                )),
          ),
          ListTile(
            title: Text(
              'Add a new Category',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            trailing: Icon(Icons.add, color: Colors.grey.shade800),
            onTap: () {
              slideRightWidget(
                  newPage: const CategoriesOpsPage(), context: context);
            },
          ),
          ListTile(
            title: Text(
              'Add a new Product',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            trailing: Icon(Icons.add, color: Colors.grey.shade800),
            onTap: () {
              slideRightWidget(
                  newPage: const ProductsOpsPage(), context: context);
            },
          ),
          ListTile(
            title: Text(
              'Add a new Client',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            trailing: Icon(Icons.add, color: Colors.grey.shade800),
            onTap: () {
              slideRightWidget(
                  newPage: const ClientsOpsPage(), context: context);
            },
          ),
          ListTile(
            title: Text(
              'Add a new Order',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            trailing: Icon(Icons.add, color: Colors.grey.shade800),
            onTap: () {
              slideRightWidget(
                  newPage: SalesOpsPage(
                    selectedOrderItems: [],
                  ),
                  context: context);
            },
          ),
          ListTile(
            title: Text(
              'About',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            trailing: Icon(Icons.error_outline, color: Colors.grey.shade800),
            onTap: () {
              slideRightWidget(newPage: const AboutApp(), context: context);
            },
          ),
        ],
      ),
    );
  }
}
