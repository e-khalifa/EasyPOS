import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../helpers/sql_helper.dart';
import '../../models/product.dart';
import '../../widgets/app_widgets/app_search_field.dart';
import '../../widgets/product_grid_view.dart';
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
  const ProductsListPage({super.key});

  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var sqlHelper = GetIt.I.get<SqlHelper>();
  List<Product> products = [];
  String? selectedSorting = 'Modification time';
  StockFilter currentFilter = StockFilter.all;
  bool notFoundOnSearch = false;

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void _handleTabSelection() {
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
        appBar: AppBar(
          toolbarHeight: 124,
          title: const Text('Products'),
          actions: [
            PopupMenuButton<String>(
                constraints:
                    const BoxConstraints.expand(width: 150, height: 115),
                surfaceTintColor: Colors.white,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Refresh',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Refresh'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Sort by',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Sort by'),
                        ),
                      ),
                    ],
                onSelected: (String choice) {
                  if (choice == 'Sort by') {
                    showMenu<String>(
                      constraints:
                          const BoxConstraints.expand(width: 180, height: 305),
                      surfaceTintColor: Colors.white,
                      context: context,
                      position:
                          const RelativeRect.fromLTRB(double.infinity, 0, 0, 0),
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
                    getProducts();
                  }
                })
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TabBar(
                        dividerColor: Colors.grey,
                        controller: _tabController,
                        unselectedLabelColor: Colors.white,
                        labelColor: Colors.black,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: Colors.white,
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        tabs: const [
                          Tab(text: 'All'),
                          Tab(text: 'Inventory'),
                          Tab(text: 'Out-of-Stock')
                        ]),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.only(top: 20, right: 20, left: 20),
                    child: AppSearchField(
                      label: 'Search for any Product',
                      //if the search field is empty, nothing change

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
                            products = data
                                .map((item) => Product.fromJson(item))
                                .toList();

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
                  )
                ],
              )),
        ),
        body: products.isEmpty
            ? notFoundOnSearch
                ? const SizedBox()
                : const Center(
                    child: Text('No Categories Found'),
                  )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Expanded(
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.70,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          print('Product: ${product.name}');

                          //calling listcard
                          return ProductGridViewItem(
                              imageUrl: product.image,
                              name: product.name,
                              description: product.description,
                              category: product.categoryName,
                              stock: product.stock,
                              price: product.price,
                              onDeleted: () => onDeleteProduct(product),
                              onEdit: () {
                                slideRightWidget(
                                    newPage: ProductsOpsPage(product: product),
                                    context: context);
                              });
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
  Future<void> onDeleteProduct(Product product) async {
    await sqlHelper.db!
        .delete('products', where: 'id =?', whereArgs: [product.id]);
    getProducts();
  }
}
