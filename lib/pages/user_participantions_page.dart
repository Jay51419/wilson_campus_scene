import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/services/eventparticipant.dart';
import 'package:wilson_campus_scene/services/eventstore.dart';
import 'package:wilson_campus_scene/services/subeventstore.dart';

class UserParticipantsPage extends StatefulWidget {
  const UserParticipantsPage({super.key});

  @override
  State<UserParticipantsPage> createState() => _UserParticipantsPageState();
}

class _UserParticipantsPageState extends State<UserParticipantsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Participants',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: StreamBuilder<List<EventParticipant>?>(
          stream: EventParticipantStoreService()
              .getAllByUser(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No Applications found'));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: const BoxDecoration(
                      border: Border(
                    bottom: BorderSide(color: Colors.grey),
                  )),
                  child: Column(
                    children: [
                      StreamBuilder<Event?>(
                          stream: EventstoreService()
                              .get(snapshot.data![index].eventId!),
                          builder: (context, event) {
                            if (event.hasError) {
                              return const SizedBox();
                            }
                            if (event.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(event.data!.title!),
                                ),
                                ListTile(
                                    title: const Text("Status"),
                                    trailing:
                                        Text(snapshot.data![index].status!))
                              ],
                            );
                          }),
                          StreamBuilder<SubEvent?>(
                          stream: SubEventStoreService()
                              .get(snapshot.data![index].eventId!),
                          builder: (context, subEvent) {
                            if (subEvent.hasError) {
                              return const SizedBox();
                            }
                            if (subEvent.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return Column(
                              children: [
                                ListTile(
                                  title: StreamBuilder<Event?>(
                                    stream: EventstoreService().get(subEvent.data!.eventID!),
                                    builder: (context, event) {
                                      return Text(event.data!.title ?? "",style: const TextStyle(fontSize: 20),);
                                    }
                                  ),
                                  subtitle: Text(subEvent.data!.title!),
                                ),
                                ListTile(
                                    title: const Text("Status"),
                                    trailing:
                                        Text(snapshot.data![index].status!))
                              ],
                            );
                          })
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}
