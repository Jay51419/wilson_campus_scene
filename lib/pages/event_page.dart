import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/pages/departments_page.dart';
import 'package:wilson_campus_scene/pages/edit_event_page.dart';
import 'package:wilson_campus_scene/pages/event_applicants.dart';
import 'package:wilson_campus_scene/pages/event_participants.dart';
import 'package:wilson_campus_scene/pages/subevents_page.dart';
import 'package:wilson_campus_scene/services/eventapplication.dart';
import 'package:wilson_campus_scene/services/eventparticipant.dart';
import 'package:wilson_campus_scene/services/eventstore.dart';
import 'package:wilson_campus_scene/services/types.dart';
import 'package:wilson_campus_scene/services/user.dart';

class EventPage extends StatefulWidget {
  final String id;
  const EventPage({super.key, required this.id});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event?>(
        stream: EventstoreService().get(widget.id),
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  snapshot.data?.title ?? "",
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
                        Text(
                          snapshot.data?.description ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        ListTile(
                          title: const Text("Department"),
                          trailing: Text(snapshot.data?.department ?? ""),
                        ),
                        ListTile(
                          title: const Text('Start Date'),
                          trailing:
                              Text(_formatDate(snapshot.data!.startDate!)),
                        ),
                        ListTile(
                          title: const Text('End Date'),
                          trailing: Text(_formatDate(snapshot.data!.endDate!)),
                        ),
                        ListTile(
                          title: const Text('Registeration Start Date'),
                          trailing: Text(_formatDate(
                              snapshot.data!.registrationStartDate!)),
                        ),
                        ListTile(
                          title: const Text('Registeration End Date'),
                          trailing: Text(
                              _formatDate(snapshot.data!.registrationEndDate!)),
                        ),
                        if (snapshot.data!.hasCoordinators!)
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey),
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: ListTile(
                                title: const Text('Coordinators'),
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
                                          EventApplicationStoreService()
                                              .create(
                                                  eventApplication:
                                                      EventApplication(
                                                eventID: snapshot.data!.id,
                                                userID: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                appliedFor: EventApplicationRole
                                                    .coordinator,
                                              ))
                                              .then((value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(value),
                                                    ),
                                                  ));
                                        },
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (snapshot.data!.hasVolunteers!)
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey),
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: ListTile(
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
                                      : () {
                                          EventApplicationStoreService()
                                              .create(
                                                  eventApplication:
                                                      EventApplication(
                                                eventID: snapshot.data!.id,
                                                userID: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                appliedFor: EventApplicationRole
                                                    .volunteer,
                                              ))
                                              .then((value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(value),
                                                    ),
                                                  ));
                                        },
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (snapshot.data!.hasEventDepartments!)
                          ListTile(
                            title: const Text('Departments'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DepartmentsPage(
                                    eventID: snapshot.data!.id!);
                              }));
                            },
                          ),
                        if (snapshot.data!.hasSubEvents!)
                          ListTile(
                            title: const Text('Events'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SubEventsPage(
                                    eventID: snapshot.data!.id!);
                              }));
                            },
                          ),
                        StreamBuilder<WilsonUser?>(
                            stream: WilsonUserStoreService()
                                .get(FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, u) {
                              if (u.data?.role == WilsonUserRole.admin) {
                                return Column(
                                  children: [
                                    ListTile(
                                      title: const Text('Applicants'),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return EventApplicantsPage(
                                              eventID: snapshot.data!.id!);
                                        }));
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('Participants'),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return EventPartcipantsPage(
                                              eventId: snapshot.data!.id!);
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
                                                title:
                                                    const Text("Delete Event"),
                                                content: const Text(
                                                    "Are you sure you want to delete this event?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        EventstoreService()
                                                            .delete(snapshot
                                                                .data!.id!).then((value) {
                                                                   EventApplicationStoreService().deleteByEventId(snapshot.data!.id!).then((value) => EventParticipantStoreService().deleteByEventId(snapshot.data!.id!));
                                                                });
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
                              return const SizedBox();
                            }),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: snapshot.data!.hasParticipants!
                  ? MaterialButton(
                      height: 80,
                      onPressed: snapshot.data!.registrationStartDate!
                                  .isAfter(DateTime.now()) ||
                              snapshot.data!.registrationEndDate!
                                  .isBefore(DateTime.now())
                          ? null
                          : () async {
                              EventParticipantStoreService()
                                  .create(
                                      eventParticipant: EventParticipant(
                                    eventId: snapshot.data!.id,
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                  ))
                                  .then((value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(value),
                                        ),
                                      ));
                            },
                      color: Colors.black,
                      textColor: Colors.white,
                      child: const Text('Participate'),
                    )
                  : null,
              floatingActionButton: StreamBuilder<WilsonUser?>(
                  stream: WilsonUserStoreService()
                      .get(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, u) {
                    if (u.data?.role == WilsonUserRole.admin) {
                      return FloatingActionButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EditEventPage(
                                event: snapshot.data!,
                              );
                            }));
                          },
                          backgroundColor: Colors.black,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ));
                    }
                    return const SizedBox();
                  }));
        });
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }
}
