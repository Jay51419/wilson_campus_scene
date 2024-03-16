import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/services/subeventstore.dart';


class CreateSubEventPage extends StatefulWidget {
  final String eventID;
  const CreateSubEventPage({super.key, required this.eventID});

  @override
  State<CreateSubEventPage> createState() => _CreateSubEventPageState();
}

class _CreateSubEventPageState extends State<CreateSubEventPage> {
  final _formKey = GlobalKey<FormState>();
  var hasParticipants = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _registrationStartDate;
  late DateTime _registrationEndDate;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _registrationStartDate = DateTime.now();
    _registrationEndDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Event',
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
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    ListTile(
                      title: const Text('Start Date'),
                      trailing: TextButton(
                        onPressed: () => _selectStartDate(context),
                        child: Text(
                          _formatDate(_startDate),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('End Date'),
                      trailing: TextButton(
                        onPressed: () => _selectEndDate(context),
                        child: Text(
                          _formatDate(_endDate),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Registeration Start Date'),
                      trailing: TextButton(
                        onPressed: () => _selectRegisterationStartDate(context),
                        child: Text(
                          _formatDate(_registrationStartDate),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Registeration End Date'),
                      trailing: TextButton(
                        onPressed: () => _selectRegisterationEndDate(context),
                        child: Text(
                          _formatDate(_registrationEndDate),
                        ),
                      ),
                    ),
                    
                    ListTile(
                      title: const Text('Participants'),
                      trailing: Switch(
                        value: hasParticipants,
                        onChanged: (value) {
                          setState(() {
                            hasParticipants = value;
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
            _createEvent();
          },
          height: 80,
          color: Colors.black,
          child: const Text(
            "Create",
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(
        () {
          _startDate = picked;
        },
      );
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _selectRegisterationStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationStartDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _registrationStartDate) {
      setState(() {
        _registrationStartDate = picked;
      });
    }
  }

  void _selectRegisterationEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationEndDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _registrationEndDate) {
      setState(() {
        _registrationEndDate = picked;
      });
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      final event = SubEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        registrationStartDate: _registrationStartDate,
        registrationEndDate: _registrationEndDate,
        eventID: widget.eventID,
        hasParticipants: hasParticipants,
      );
      SubEventStoreService().create(subEvent: event).then((eventID) =>Navigator.pop(context));
    }
  }
}
