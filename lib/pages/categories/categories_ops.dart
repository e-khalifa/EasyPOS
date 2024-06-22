import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/sql_helper.dart';
import '../../models/category.dart';
import '../../widgets/app_widgets/app_elevated_button.dart';
import '../../widgets/app_widgets/app_text_field.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      // Setting initial values for editing an existing category
      nameController.text = widget.category!.name!;
      descriptionController.text = widget.category!.description!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add New' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              AppTextField(
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
              AppTextField(
                  label: 'Description', controller: descriptionController),
              const SizedBox(height: 20),
              AppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmittedCategory();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  //if the controllers are empty, add a new category, if it's not, update
  Future<void> onSubmittedCategory() async {
    if (formKey.currentState!.validate()) {
      if (widget.category == null) {
        // Adding a new category
        await sqlHelper.db!.insert(
          'categories',
          conflictAlgorithm: ConflictAlgorithm.replace,
          {
            'name': nameController.text,
            'description': descriptionController.text,
          },
        );
      } else {
        // Updating an existing category
        await sqlHelper.db!.update(
          'categories',
          {
            'name': nameController.text,
            'description': descriptionController.text,
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
                : 'Category Updated Successfully!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      //updated ones don't appear immediately after editing?
      Navigator.pop(context, true);
    }
  }
}
