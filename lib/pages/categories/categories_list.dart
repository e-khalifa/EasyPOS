import 'package:easy_pos_project/widgets/app_widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../helpers/sql_helper.dart';
import '../../models/category.dart';
import '../../widgets/app_widgets/my_card.dart';
import 'categories_ops.dart';

enum StatusFilter { all, newArrivals, specialOffers }

class CategoriesListPage extends StatefulWidget {
  const CategoriesListPage({super.key});

  @override
  _CategoriesListPageState createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var sqlHelper = GetIt.I.get<SqlHelper>();
  String? selectedSorting;
  List<Category> categories = [];
  StatusFilter currentFilter = StatusFilter.all;
  bool notFoundOnSearch = false;
  bool isLoading = false;
  var sortingChoices = [
    'Modification time',
    'Name',
  ];

  @override
  void initState() {
    getCategories(); // Fetch categories when the widget initializes
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          currentFilter = StatusFilter.all;
          break;
        case 1:
          currentFilter = StatusFilter.newArrivals;
          break;
        case 2:
          currentFilter = StatusFilter.specialOffers;
          break;
      }
      getCategories(filter: currentFilter, sort: selectedSorting);
    });
  }

  //mapping data to list
  Future<void> getCategories(
      {StatusFilter filter = StatusFilter.all, String? sort}) async {
    String query;
    switch (filter) {
      case StatusFilter.newArrivals:
        query = '''
  SELECT * FROM categories 
  WHERE status LIKE '%New Arrivals%'
''';
        break;
      case StatusFilter.specialOffers:
        query = '''
  SELECT * FROM categories 
  WHERE status LIKE '%Special Offers%'
''';
        break;
      default:
        query = '''
  SELECT * FROM categories 
''';
    }
    try {
      var data = await sqlHelper.db!.rawQuery(query);
      if (data.isNotEmpty) {
        categories = data.map((item) => Category.fromJson(item)).toList();
      } else {
        categories = [];
      }
      if (sort != null) {
        applySorting(sort);
      }
    } catch (e) {
      print('Error in get Categories: $e');
    }
    setState(() {});
  }

  void applySorting(String sort) {
    switch (sort) {
      case 'Name':
        categories.sort((a, b) => a.name!.compareTo(b.name!));
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
          title: ('Categories'),
          sortingChoices: sortingChoices,
          onSelected: (String choice) async {
            if (choice == 'Sort by') {
              showMenu<String>(
                constraints:
                    const BoxConstraints.expand(width: 180, height: 110),
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
                  getCategories(filter: currentFilter, sort: value);
                }
              });
            } else if (choice == 'Refresh') {
              setState(() {
                isLoading = true; // Show the loading indicator
              });

              // Introduce a delay before calling the function
              await Future.delayed(Duration(milliseconds: 600));
              await getCategories(filter: currentFilter, sort: selectedSorting);

              // Hide the loading indicator
              setState(() {
                isLoading = false;
              });
            }
          },
          Controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'New Arrivals'),
            Tab(text: 'Special Offers')
          ],
          searchLabel: 'Search for any Category',
          onSearchTextChanged: (text) async {
            if (text.isEmpty) {
              getCategories();
              return;
            }

            //search the data for the text provided
            final data = await sqlHelper.db!.rawQuery('''
                      SELECT * FROM categories 
                      WHERE name LIKE '%$text%' OR description LIKE '%$text%'
                    ''');

            //if anything related found, map it to a list
            if (data.isNotEmpty) {
              categories = data.map((item) => Category.fromJson(item)).toList();

              //nothing found? empty list
            } else {
              categories = [];
            }
            setState(() {});
          },
        ),
        body: categories.isEmpty
            ? notFoundOnSearch
                ? const SizedBox()
                : const Center(
                    child: Text('No Categories Found'),
                  )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 3,
                          )
                        : SizedBox(),
                    Expanded(
                      child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            print('Category: ${category.name}');

                            //caling listcard
                            return MyCard(
                              onDeleted: () => onDeleteCategory(category),
                              onEdit: () {
                                slideRightWidget(
                                    newPage:
                                        CategoriesOpsPage(category: category),
                                    context: context);
                              },
                              name: category.name,
                              customWidget: Text(
                                category.description!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }),
                    ),
                  ],
                )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            var updated = await pushWidgetAwait(
              newPage: const CategoriesOpsPage(),
              context: context,
            );
            if (updated == true) {
              getCategories();
            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  //Deleting category
  Future<void> onDeleteCategory(Category category) async {
    await sqlHelper.db!
        .delete('categories', where: 'id =?', whereArgs: [category.id]);
    getCategories();
  }
}
