import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/pages/edit_subevent_page.dart';
import 'package:wilson_campus_scene/pages/event_participants.dart';
import 'package:wilson_campus_scene/services/eventparticipant.dart';
import 'package:wilson_campus_scene/services/subeventstore.dart';
import 'package:wilson_campus_scene/services/user.dart';

class SubEventPage extends StatefulWidget {
  final String id;
  const SubEventPage({super.key, required this.id});

  @override
  State<SubEventPage> createState() => _SubEventPageState();
}

class _SubEventPageState extends State<SubEventPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SubEvent?>(
        stream: SubEventStoreService().get(widget.id),
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
                        title: const Text('Start Date'),
                        trailing: Text(_formatDate(snapshot.data!.startDate!)),
                      ),
                      ListTile(
                        title: const Text('End Date'),
                        trailing: Text(_formatDate(snapshot.data!.endDate!)),
                      ),
                      ListTile(
                        title: const Text('Registeration Start Date'),
                        trailing: Text(
                            _formatDate(snapshot.data!.registrationStartDate!)),
                      ),
                      ListTile(
                        title: const Text('Registeration End Date'),
                        trailing: Text(
                            _formatDate(snapshot.data!.registrationEndDate!)),
                      ),
                      StreamBuilder<WilsonUser?>(
                          stream: WilsonUserStoreService()
                              .get(FirebaseAuth.instance.currentUser!.uid),
                          builder: (context, u) {
                            if (u.data?.role == WilsonUserRole.admin) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: const Text('Participants'),
                                    trailing: Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return EventPartcipantsPage(
                                            eventId: snapshot.data!.id!);
                                      }));
                                    },
                                  ),
                                  const Divider(color: Colors.grey,),
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
                                                        SubEventStoreService()
                                                            .delete(snapshot
                                                                .data!.id!).then((value) => 
                                                                EventParticipantStoreService().deleteByEventId(snapshot.data!.id!));
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
                                .then((value) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                          return EditSubEventPage(
                            event: snapshot.data!,
                          );
                        }));
                      },
                      backgroundColor: Colors.black,
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    );
                  }
                  return SizedBox();
                }),
          );
        });
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }
}
