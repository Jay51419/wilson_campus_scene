import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/pages/department_applicant.dart';
import 'package:wilson_campus_scene/pages/edit_department_page.dart';
import 'package:wilson_campus_scene/services/eventdepartment.dart';
import 'package:wilson_campus_scene/services/eventdepartmentapplication.dart';
import 'package:wilson_campus_scene/services/eventstore.dart';
import 'package:wilson_campus_scene/services/types.dart';
import 'package:wilson_campus_scene/services/user.dart';

class DepartmentPage extends StatefulWidget {
  final String id;
  const DepartmentPage({super.key, required this.id});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventDepartment?>(
        stream: EventDepartmentStoreService().get(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                snapshot.data?.name ?? "",
                style: const TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              backgroundColor: Colors.black,
            ),
            body: SafeArea(
              top: true,
              bottom: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (snapshot.data!.hasHOD!)
                        StreamBuilder<Event?>(
                            stream: EventstoreService()
                                .get(snapshot.data!.eventID!),
                            builder: (context, snapshot) {
                              return ListTile(
                                title: const Text('HOD'),
                                trailing: MaterialButton(
                                  disabledColor: Colors.grey,
                                  color: Colors.black,
                                  onPressed: snapshot
                                              .data!.registrationStartDate!
                                              .isAfter(DateTime.now()) ||
                                          snapshot.data!.registrationEndDate!
                                              .isBefore(DateTime.now())
                                      ? null // Registration has not started or has ended, disable button
                                      : () async {
                                          EventDepartmentApplicationStoreService()
                                              .create(
                                                eventDepartmentApplication:
                                                    EventDepartmentApplication(
                                                  appliedFor:
                                                      EventDepartmentApplicationRole
                                                          .hod,
                                                  userId: FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  eventId: snapshot.data!.id,
                                                  eventDepartmentId: widget.id,
                                                ),
                                              )
                                              .then((value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(value),
                                                  )));
                                        },
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }),
                      if (snapshot.data!.hasVolunteers!)
                        StreamBuilder<Event?>(
                            stream: EventstoreService()
                                .get(snapshot.data!.eventID!),
                            builder: (context, snapshot) {
                              return ListTile(
                                title: const Text('Volunteers'),
                                trailing: MaterialButton(
                                  disabledColor: Colors.grey,
                                  color: Colors.black,
                                  onPressed: snapshot
                                              .data!.registrationStartDate!
                                              .isAfter(DateTime.now()) ||
                                          snapshot.data!.registrationEndDate!
                                              .isBefore(DateTime.now())
                                      ? null // Registration has not started or has ended, disable button
                                      : () async {
                                          EventDepartmentApplicationStoreService()
                                              .create(
                                                eventDepartmentApplication:
                                                    EventDepartmentApplication(
                                                  appliedFor:
                                                      EventDepartmentApplicationRole
                                                          .volunteer,
                                                  userId: FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  eventId: snapshot.data!.id,
                                                  eventDepartmentId: widget.id,
                                                ),
                                              )
                                              .then((value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(value),
                                                  )));
                                        },
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }),
                      StreamBuilder<WilsonUser?>(
                          stream: WilsonUserStoreService()
                              .get(FirebaseAuth.instance.currentUser!.uid),
                          builder: (context, u) {
                            if (u.data?.role == WilsonUserRole.admin) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text("Applicants"),
                                    trailing: Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return DepartmentApplicantsPage(
                                          departmentId: snapshot.data!.id!,
                                        );
                                      }));
                                    },
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Delete Event"),
                                              content: const Text(
                                                  "Are you sure you want to delete this event?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      EventDepartmentStoreService()
                                                          .delete(snapshot
                                                              .data!.id!)
                                                          .then((value) =>
                                                              EventDepartmentApplicationStoreService()
                                                                  .deleteByEventDepartmentId(
                                                                      snapshot
                                                                          .data!
                                                                          .id!));
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Yes")),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("No"))
                                              ],
                                            );
                                          });
                                    },
                                    child: const Text(
                                      "Delete Event",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                ],
                              );
                            }
                            return SizedBox();
                          })
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: StreamBuilder<WilsonUser?>(
                stream: WilsonUserStoreService()
                    .get(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, u) {
                  if (u.data?.role == WilsonUserRole.admin) {
                    return FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return EditDepartmentPage(
                              eventDepartment: snapshot.data!,
                            );
                          }),
                        );
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.black,
                    );
                  }
                  return SizedBox();
                }),
          );
        });
  }
}
