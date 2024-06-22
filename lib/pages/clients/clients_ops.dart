import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/sql_helper.dart';
import '../../models/client.dart';
import '../../widgets/app_widgets/app_elevated_button.dart';
import '../../widgets/app_widgets/app_text_field.dart';

class ClientsOpsPage extends StatefulWidget {
  final Client? client;
  const ClientsOpsPage({this.client, super.key});

  @override
  State<ClientsOpsPage> createState() => _ClientsOpsPageState();
}

class _ClientsOpsPageState extends State<ClientsOpsPage> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  var formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      // Setting initial values for editing an existing client
      nameController.text = widget.client!.name!;
      phoneController.text = widget.client!.phone!;
      addressController.text = widget.client!.address!;
      emailController.text = widget.client!.email!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Add New Client' : 'Edit Client'),
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
                label: 'phone',
                controller: phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This Field is required';
                  }
                  if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                    return 'Please enter a valid 11-digit phone number';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppTextField(label: 'address', controller: addressController),
              const SizedBox(height: 20),
              AppTextField(label: 'Email', controller: emailController),
              const SizedBox(height: 20),
              AppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmittedClient();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  //if the controllers are empty, add a new client, if it's not, update
  Future<void> onSubmittedClient() async {
    if (formKey.currentState!.validate()) {
      if (widget.client == null) {
        // Adding a new client
        await sqlHelper.db!.insert(
          'clients',
          conflictAlgorithm: ConflictAlgorithm.replace,
          {
            'name': nameController.text,
            'phone': phoneController.text,
            'address': addressController.text,
            'email': emailController.text,
          },
        );
      } else {
        // Updating an existing client
        await sqlHelper.db!.update(
          'clients',
          {
            'name': nameController.text,
            'phone': phoneController.text,
            'address': addressController.text,
            'email': emailController.text,
          },
          where: 'id =?',
          whereArgs: [widget.client?.id],
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.client == null
                ? 'Client added Successfully!'
                : 'Client Updated Successfully!',
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
