import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/sql_helper.dart';
import '../../models/category.dart';
import '../../widgets/buttons/my_elevated_button.dart';
import '../../widgets/text_field/my_text_field.dart';

class CategoriesOpsPage extends StatefulWidget {
  final Category? category;
  const CategoriesOpsPage({this.category, super.key});

  @override
  State<CategoriesOpsPage> createState() => _CategoriesOpsPageState();
}

class _CategoriesOpsPageState extends State<CategoriesOpsPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  var formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String? selectedStatus;

  @override
  void initState() {
    try {
      if (widget.category != null) {
        // Setting initial values for editing an existing category
        nameController.text = widget.category!.name!;
        descriptionController.text = widget.category!.description!;
        selectedStatus = widget.category!.selectedStatus;
      }
    } catch (e) {
      // Handle the error
      print('An error occurred in edditing category: $e');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add New' : 'Edit Category'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                MyTextField(
                  label: 'Name',
                  controller: nameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'This Field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextField(
                    label: 'Description', controller: descriptionController),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 25, right: 10),
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
                  hint: Text('Choose Category Status'),
                  isExpanded: true,
                  items: ['New Arrivals', 'Special Offers'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    try {
                      setState(() {
                        selectedStatus = value;
                        print('$selectedStatus');
                      });
                      print('$selectedStatus');
                    } catch (e) {
                      print('An error occurredi in adding status: $e');
                    }
                  },
                ),
                const SizedBox(height: 20),
                MyElevatedButton(
                    label: 'Submit',
                    onPressed: () async {
                      await onSubmittedCategory();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //if the controllers are empty, add a new category, if it's not, update
  Future<void> onSubmittedCategory() async {
    try {
      if (formKey.currentState!.validate()) {
        if (widget.category == null) {
          // Adding a new category
          await sqlHelper.db!.insert(
            'categories',
            conflictAlgorithm: ConflictAlgorithm.replace,
            {
              'name': nameController.text,
              'description': descriptionController.text,
              'status': selectedStatus,
            },
          );
        } else {
          // Updating an existing category
          await sqlHelper.db!.update(
            'categories',
            {
              'name': nameController.text,
              'description': descriptionController.text,
              'status': selectedStatus,
            },
            where: 'id =?',
            whereArgs: [widget.category?.id],
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              widget.category == null
                  ? 'Category added Successfully!'
                  : 'Changes saved! Refresh to view the updtaed items',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
        //updated ones don't appear immediately after editing?
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('An error occurred in onSubmittedCategory: $e');
    }
  }
}
