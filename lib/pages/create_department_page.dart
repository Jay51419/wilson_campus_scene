import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/services/eventdepartment.dart';

class CreateDepartmentPage extends StatefulWidget {
  final String eventID;
  const CreateDepartmentPage({super.key, required this.eventID});

  @override
  State<CreateDepartmentPage> createState() => _CreateDepartmentPageState();
}

class _CreateDepartmentPageState extends State<CreateDepartmentPage> {
  final _formKey = GlobalKey<FormState>();
  var hasHOD = false;
  var hasVolunteers = false;
  late TextEditingController _titleController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Department',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
        ),
        body: SafeArea(
          top: true,
          bottom: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    ListTile(
                      title: const Text('HOD'),
                      trailing: Switch(
                        value: hasHOD,
                        onChanged: (value) {
                          setState(() {
                            hasHOD = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Volunteers'),
                      trailing: Switch(
                        value: hasVolunteers,
                        onChanged: (value) {
                          setState(() {
                            hasVolunteers = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: MaterialButton(
          onPressed: () {
            _createEvent(context);
          },
          height: 80,
          color: Colors.black,
          child: const Text(
            "Create",
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  void _createEvent(context) {
    if (_formKey.currentState!.validate()) {
      final event = EventDepartment(
        name: _titleController.text,
        hasHOD: hasHOD,
        hasVolunteers: hasVolunteers,
        eventID: widget.eventID,
      );
      EventDepartmentStoreService()
          .create(eventDepartment: event)
          .then((eventID) => Navigator.pop(context));
    }
  }
}
