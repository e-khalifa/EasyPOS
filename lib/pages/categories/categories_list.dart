import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../helpers/sql_helper.dart';
import '../../models/category.dart';
import '../../widgets/app_widgets/app_search_field.dart';
import '../../widgets/list_card.dart';
import 'categories_ops.dart';

class CategoriesListPage extends StatefulWidget {
  const CategoriesListPage({super.key});

  @override
  _CategoriesListPageState createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();
  List<Category> categories = [];

  @override
  void initState() {
    getCategories(); // Fetch categories when the widget initializes
    super.initState();
  }

  //mapping data to list
  Future<void> getCategories() async {
    try {
      var data = await sqlHelper.db!.query('categories');
      if (data.isNotEmpty) {
        categories = data.map((item) => Category.fromJson(item)).toList();
      } else {
        categories = [];
      }
    } catch (e) {
      print('Error in get Categories: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ),

                //updating getCategories function after adding or updating any category
                onPressed: () async {
                  var updated = await pushWidgetAwait(
                      newPage: const CategoriesOpsPage(), context: context);
                  if (updated == true) {
                    getCategories();
                  }
                }),
          ],
        ),
        body: categories.isEmpty
            ? const Center(
                child: Text('No Categories Found'),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    //calling searchfield
                    AppSearchField(
                      label: 'Search for any Category',

                      //if the search field is empty, nothing change
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
                          categories = data
                              .map((item) => Category.fromJson(item))
                              .toList();

                          //nothing found? empty list
                        } else {
                          categories = [];
                        }
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            print('Category: ${category.name}');

                            //caling listcard
                            return ListCard(
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
                )));
  }

  //Deleting category
  Future<void> onDeleteCategory(Category category) async {
    await sqlHelper.db!
        .delete('categories', where: 'id =?', whereArgs: [category.id]);
    getCategories();
  }
}
