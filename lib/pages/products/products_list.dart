import 'package:easy_pos_project/widgets/app_widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../helpers/sql_helper.dart';
import '../../models/product.dart';
import '../../widgets/app_widgets/my_item_deleted_dialog.dart';
import '../../widgets/products_widgets/product_grid_view.dart';
import 'products_ops.dart';

/*
Products:
        1- Name
        2- Description
        3- Category Name
        4- Price
        5- In Stock
        6- isAvailable
*/
enum StockFilter { all, inventory, outOfStock }

class ProductsListPage extends StatefulWidget {
  int selectedTabIndex;
  ProductsListPage({required this.selectedTabIndex, super.key});

  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var sqlHelper = GetIt.I.get<SqlHelper>();
  List<Product> products = [];
  String? selectedSorting;
  StockFilter currentFilter = StockFilter.all;
  bool notFoundOnSearch = false;
  bool isLoading = false;

  var sortingChoices = [
    'Modification time',
    'Name',
    'Price ⬆',
    'Price ⬇',
    'Stock ⬆',
    'Stock ⬇',
  ];

  @override
  void initState() {
    getProducts(); // Fetch Products when the widget initializes
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.selectedTabIndex);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void _handleTabSelection() {
    try {
      if (_tabController.indexIsChanging) return;
      setState(() {
        switch (_tabController.index) {
          case 0:
            currentFilter = StockFilter.all;
            break;
          case 1:
            currentFilter = StockFilter.inventory;
            break;
          case 2:
            currentFilter = StockFilter.outOfStock;
            break;
        }
        getProducts(filter: currentFilter, sort: selectedSorting);
      });
    } catch (e) {
      print('Error in filtering products $e');
    }
  }

  //mapping data to list
  Future<void> getProducts(
      {StockFilter filter = StockFilter.all, String? sort}) async {
    String query;
    switch (filter) {
      case StockFilter.inventory:
        query = """
        SELECT P.*, C.name as categoryName FROM products P
        INNER JOIN categories C ON P.categoryId = C.id
        WHERE P.stock >= 1
      """;
        break;
      case StockFilter.outOfStock:
        query = """
        SELECT P.*, C.name as categoryName FROM products P
        INNER JOIN categories C ON P.categoryId = C.id
        WHERE P.stock < 1
      """;
        break;
      default:
        query = """
        SELECT P.*, C.name as categoryName FROM products P
        INNER JOIN categories C ON P.categoryId = C.id
      """;
    }

    try {
      // Execute the query and fetch data
      var data = await sqlHelper.db!.rawQuery(query);

      // Map data to products list
      if (data.isNotEmpty) {
        products = data.map((item) => Product.fromJson(item)).toList();
      } else {
        products = [];
      }
      // Apply sorting if a sort parameter is provided
      if (sort != null) {
        applySorting(sort);
      }
    } catch (e) {
      print('Error in get products: $e');
    }
    setState(() {});
  }

  void applySorting(String sort) {
    switch (sort) {
      case 'Name':
        products.sort((a, b) => a.name!.compareTo(b.name!));
        break;
      case 'Price ⬆':
        products.sort((a, b) => a.price!.compareTo(b.price!));
        break;
      case 'Price ⬇':
        products.sort((a, b) => b.price!.compareTo(a.price!));
        break;
      case 'Stock ⬆':
        products.sort((a, b) => a.stock!.compareTo(b.stock!));
        break;
      case 'Stock ⬇':
        products.sort((a, b) => b.stock!.compareTo(a.stock!));
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: 'Products',
          sortingChoices: sortingChoices,
          onSelected: (String choice) async {
            if (choice == 'Sort by') {
              showMenu<String>(
                constraints:
                    const BoxConstraints.expand(width: 180, height: 305),
                surfaceTintColor: Colors.white,
                context: context,
                position: const RelativeRect.fromLTRB(double.infinity, 0, 0, 0),
                items: sortingChoices.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(item),
                    ),
                  );
                }).toList(),
              ).then((String? value) {
                if (value != null) {
                  setState(() {
                    selectedSorting = value;
                  });
                  getProducts(filter: currentFilter, sort: value);
                }
              });
            } else if (choice == 'Refresh') {
              setState(() {
                isLoading = true; // Show the loading indicator
              });

              // Introduce a delay before calling the function
              await Future.delayed(Duration(milliseconds: 600));
              await getProducts(filter: currentFilter, sort: selectedSorting);

              // Hide the loading indicator
              setState(() {
                isLoading = false;
              });
            }
          },
          Controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Inventory'),
            Tab(text: 'Out-of-Stock')
          ],

          //Searchbar
          searchLabel: 'Search for any Product',
          onSearchTextChanged: (text) async {
            try {
              if (text.isEmpty) {
                getProducts();
                return;
              }

              //search the data (name/desciption) for the text provided
              final data = await sqlHelper.db!.rawQuery('''
                                    SELECT P.*, C.name as categoryName FROM products P
                                    INNER JOIN categories C ON P.categoryId = C.id
                                    WHERE P.name LIKE '%$text%'
                                    OR P.description LIKE '%$text%'
                                    Or c.name LIKE '%$text%'
                                  ''');

              //if anything related found, map it to a list
              if (data.isNotEmpty) {
                products = data.map((item) => Product.fromJson(item)).toList();

                //nothing found? empty list
              } else {
                notFoundOnSearch = true;
                products = [];
              }
            } catch (e) {
              print('Error in search products: $e');
            }
            setState(() {});
          },
        ),
        body: products.isEmpty
            ? notFoundOnSearch
                ? const SizedBox()
                : const Center(
                    child: Text('No Products Found'),
                  )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 3,
                        )
                      : SizedBox(),
                  Expanded(
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.76,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          print('Product: ${product.name}');

                          //calling listcard
                          return ProductGridViewItem(
                              showCategory: true,
                              imageUrl: product.image,
                              name: product.name,
                              description: product.description,
                              category: product.categoryName,
                              stock: product.stock,
                              price: product.price,
                              righticon: Icons.edit,
                              rightIconColor: Theme.of(context).primaryColor,
                              rightIconPressed: () {
                                slideRightWidget(
                                    newPage: ProductsOpsPage(product: product),
                                    context: context);
                              },
                              leftIcon: Icons.delete,
                              leftIconColor: Colors.red,
                              leftIconPressed: () => onDeleteProduct(product));
                        }),
                  ),
                ]),
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            var updated = await pushWidgetAwait(
              newPage: const ProductsOpsPage(),
              context: context,
            );
            if (updated == true) {
              getProducts();
            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  //Deleting product
  Future<void> onDeleteProduct(Product product) {
    //Callling itemDeleted dialog
    return showDialog(
        context: context,
        builder: (context) {
          return MyItemDeletedDialog(
              item: product.name,
              onDeleteditem: () async {
                await sqlHelper.db!.delete('products',
                    where: 'id =?', whereArgs: [product.id]);
                getProducts();
              });
        });
  }
}
