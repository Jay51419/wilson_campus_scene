import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/services/eventapplication.dart';
import 'package:wilson_campus_scene/services/eventdepartment.dart';
import 'package:wilson_campus_scene/services/eventdepartmentapplication.dart';
import 'package:wilson_campus_scene/services/eventstore.dart';

class UserApplicationsPage extends StatefulWidget {
  const UserApplicationsPage({super.key});

  @override
  State<UserApplicationsPage> createState() => _UserApplicationsPageState();
}

class _UserApplicationsPageState extends State<UserApplicationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Applications',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: StreamBuilder<List<dynamic>>(
  stream: StreamZip([
    EventApplicationStoreService()
        .getApplicationsByUser(FirebaseAuth.instance.currentUser!.uid),
    EventDepartmentApplicationStoreService()
        .getAllByUser(FirebaseAuth.instance.currentUser!.uid),
  ]),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Something went wrong'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    List<EventApplication> eventApplications = snapshot.data![0] ?? [];
    List<EventDepartmentApplication> departmentApplications = snapshot.data![1] ?? [];

    if (eventApplications.isEmpty && departmentApplications.isEmpty) {
      return const Center(child: Text('No Applications found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: eventApplications.length + departmentApplications.length,
      itemBuilder: (BuildContext context, int index) {
        if (index < eventApplications.length) {
          return _buildEventApplicationTile(eventApplications[index]);
        } else {
          int departmentIndex = index - eventApplications.length;
          return _buildDepartmentApplicationTile(departmentApplications[departmentIndex]);
        }
      },
    );
  },
)

        );
  }
  Widget _buildEventApplicationTile(EventApplication application) {
  return DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey),
      ),
    ),
    child: Column(
      children: [
        ListTile(
          title: StreamBuilder<Event?>(
            stream: EventstoreService().get(application.eventID!),
            builder: (context, event) {
              return Text(event.data?.title ?? "", style: const TextStyle(fontSize: 18));
            },
          ),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        ListTile(
          title: const Text(
            "Applied for",
            style: TextStyle(color: Colors.black),
          ),
          trailing: Text(
            application.appliedFor!.name,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        ListTile(
          title: const Text('Status'),
          trailing: Text(
            application.status!,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDepartmentApplicationTile(EventDepartmentApplication application) {
  return DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey),
      ),
    ),
    child: Column(
      children: [
        ListTile(
          title: StreamBuilder<Event?>(
            stream: EventstoreService().get(application.eventId!),
            builder: (context, event) {
              return Text(event.data?.title ?? "", style: const TextStyle(fontSize: 18));
            },
          ),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          subtitle: StreamBuilder<EventDepartment?>(
            stream: EventDepartmentStoreService().get(application.eventDepartmentId!),
            builder: (context, department) {
              return Text(department.data?.name ?? "", style: const TextStyle(fontSize: 18));
            },
          ),
        ),
        ListTile(
          title: const Text(
            "Applied for",
            style: TextStyle(color: Colors.black),
          ),
          trailing: Text(
            application.appliedFor!.name,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        ListTile(
          title: const Text('Status'),
          trailing: Text(
            application.status!,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
}
