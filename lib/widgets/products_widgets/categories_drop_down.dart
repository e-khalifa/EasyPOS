import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../helpers/sql_helper.dart';
import '../../models/category.dart';
import '../../pages/categories/categories_ops.dart';

class CategoriesDropDown extends StatefulWidget {
  final int? selectedValue;
  final String? Function(int?)? validator;
  TextEditingController categorySearchController = TextEditingController();

  final void Function(int?)? onChanged;

  CategoriesDropDown(
      {this.selectedValue,
      required this.validator,
      required this.onChanged,
      required this.categorySearchController,
      super.key});

  @override
  State<CategoriesDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  List<Category> categories = [];

  @override
  void initState() {
    getCategories();
    super.initState();
  }

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
    try {
      return DropdownButtonFormField2<int>(
          decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.only(right: 10, top: 20, bottom: 15, left: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(width: 2, color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  width: 2,
                  color: Colors.red,
                ),
              )),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          value: widget.selectedValue,
          onChanged: widget.onChanged,
          hint: Text(categories.isNotEmpty
              ? 'Select Category'
              : 'No Categories Found'),
          items: categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Text(
                category.name ?? 'No Name',
              ),
            );
          }).toList(),

          //Drop down Menu Style
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          //Search subclass
          dropdownSearchData: DropdownSearchData(
            searchController: widget.categorySearchController,
            searchInnerWidgetHeight: 60,
            searchInnerWidget: Container(
              height: 60,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 5,
                right: 10,
                left: 10,
              ),
              child: TextFormField(
                expands: true,
                maxLines: null,
                controller: widget.categorySearchController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Search',
                  hintStyle: const TextStyle(fontSize: 12),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              var category = categories
                  .firstWhere((category) => category.id == item.value);
              return category.name!
                  .toLowerCase()
                  .contains(searchValue.toLowerCase());
            },
          ),
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              widget.categorySearchController.clear();
            }
          });
    } catch (e) {
      print('Error building CategoriesDropDown: $e');
      return const SizedBox.shrink();
    }
  }
}
