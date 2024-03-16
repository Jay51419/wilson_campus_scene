import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/services/eventdepartment.dart';

class EditDepartmentPage extends StatefulWidget {
  final EventDepartment eventDepartment;
  const EditDepartmentPage({super.key, required this.eventDepartment});
  @override
  State<EditDepartmentPage> createState() => _EditDepartmentPageState();
}

class _EditDepartmentPageState extends State<EditDepartmentPage> {
  final _formKey = GlobalKey<FormState>();
  var hasHOD = false;
  var hasVolunteers = false;
  late TextEditingController _titleController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventDepartment.name);
    hasHOD = widget.eventDepartment.hasHOD!;
    hasVolunteers = widget.eventDepartment.hasVolunteers!;
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
                              value:  hasHOD,
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
                              value: 
                                  hasVolunteers,
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
            "Update",
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  void _createEvent(context) {
    if (_formKey.currentState!.validate()) {
      final event = EventDepartment(
        id: widget.eventDepartment.id,
        name: _titleController.text,
        hasHOD: hasHOD,
        hasVolunteers: hasVolunteers,
        eventID: widget.eventDepartment.eventID,
      );
      EventDepartmentStoreService()
          .update(event)
          .then((eventID) => Navigator.pop(context));
    }
  }
}
