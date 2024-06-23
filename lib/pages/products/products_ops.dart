import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/sql_helper.dart';
import '../../models/product.dart';
import '../../widgets/app_widgets/my_elevated_button.dart';
import '../../widgets/app_widgets/my_text_field.dart';
import '../../widgets/products_widgets/categories_drop_down.dart';
import '../../widgets/products_widgets/is_available_switch.dart';

class ProductsOpsPage extends StatefulWidget {
  final Product? product;
  const ProductsOpsPage({this.product, super.key});

  @override
  State<ProductsOpsPage> createState() => _ProductsOpsPageState();
}

class _ProductsOpsPageState extends State<ProductsOpsPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  var formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final imageController = TextEditingController();
  final categoryDropdownSearchController = TextEditingController();
  bool? isAvailable;
  int? selectedCategoryId;

  @override
  void initState() {
    try {
      if (widget.product != null) {
        // Setting initial values for editing an existing product
        nameController.text = widget.product!.name!;
        descriptionController.text = widget.product!.description!;
        priceController.text = '${widget.product?.price ?? ''}';
        stockController.text = '${widget.product?.stock ?? ''}';
        imageController.text = widget.product!.image!;

        isAvailable = widget.product?.isAvailable;
        selectedCategoryId = widget.product?.categoryId;
      }
    } catch (e) {
      // Handle the error
      print('An error occurredi in edditing product: $e');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add New' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                MyTextField(
                  label: 'Product Name',
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
                  label: 'Description',
                  controller: descriptionController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'This Field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                //Calling categories drop down menu
                CategoriesDropDown(
                    selectedValue: selectedCategoryId,
                    onChanged: (value) {
                      selectedCategoryId = value;
                      setState(() {});
                    },
                    categorySearchController: categoryDropdownSearchController,
                    validator: (selectedValue) {
                      if (selectedValue == null) {
                        return 'Please select a category';
                      }
                      return null;
                    }),
                const SizedBox(height: 20),
                MyTextField(
                  label: 'Add your image URL here',
                  controller: imageController,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        label: 'Price',
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This Field is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: MyTextField(
                        label: 'Stock',
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This Field is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: IsAvailableSwitch(
                          // if the bool is nullable Convert nullable to non-nullable
                          value: isAvailable ?? false,
                          onChanged: (newValue) {
                            setState(() {
                              isAvailable = newValue;
                            });
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MyElevatedButton(
                    label: 'Submit',
                    onPressed: () async {
                      await onSubmittedProduct();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //if the controllers are empty, add a new product, if it's not, update
  Future<void> onSubmittedProduct() async {
    try {
      if (formKey.currentState!.validate()) {
        if (widget.product == null) {
          // Add a new product
          await sqlHelper.db!.insert(
            'products',
            conflictAlgorithm: ConflictAlgorithm.replace,
            {
              'name': nameController.text,
              'description': descriptionController.text,
              'price': double.parse(priceController.text),
              'stock': int.parse(stockController.text),
              'image': imageController.text,
              'categoryId': selectedCategoryId,
              'isAvailable':
                  isAvailable == true ? 1 : 0, //Convert boolean to int
            },
          );
        } else {
          // Update an existing product
          await sqlHelper.db!.update(
            'products',
            {
              'name': nameController.text,
              'description': descriptionController.text,
              'price': double.parse(priceController.text),
              'stock': int.parse(stockController.text),
              'image': imageController.text,
              'categoryId': selectedCategoryId,
              'isAvailable': isAvailable == true ? 1 : 0,
            },
            where: 'id =?',
            whereArgs: [widget.product?.id],
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              widget.product == null
                  ? 'Product added Successfully!'
                  : 'Changes saved! Refresh to view the updtaed item',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
        //updated ones don't appear immediately after editing?
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('An error occurred in onSubmittedProduct: $e');
    }
  }
}
