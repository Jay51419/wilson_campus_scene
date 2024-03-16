import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/services/user.dart';

class CreateUserInfoPage extends StatefulWidget {
  const CreateUserInfoPage({super.key});

  @override
  State<CreateUserInfoPage> createState() => _CreateUserInfoPageState();
}

class _CreateUserInfoPageState extends State<CreateUserInfoPage> {
  late TextEditingController _dController;
  final _formKey = GlobalKey<FormState>();
  String year = "First";

  @override
  void initState() {
    super.initState();
    _dController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
          body: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _dController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a deparment';
                  }
                  return null;
                },
              ),
              ListTile(
                title: const Text("Year"),
                trailing: DropdownButton<String>(
                  value: year,
                  items:
                      <String>['First', 'Second', 'Third'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) {
                        year = value;
                      }
                    });
                  },
                ),
              )
            ]),
          ),
          bottomNavigationBar: MaterialButton(
            onPressed: () {
              _updateDepartment();
            },
            height: 80,
            color: Colors.black,
            child: const Text(
              "Create",
              style: TextStyle(color: Colors.white),
            ),
          )),
    );
  }

  _updateDepartment() {
    if (_formKey.currentState!.validate()) {
      WilsonUserStoreService()
          .update(WilsonUser(
              id: FirebaseAuth.instance.currentUser!.uid,
              year: year,
              department: _dController.text))
          .then((value) => Navigator.pop(context));
    }
  }
}
