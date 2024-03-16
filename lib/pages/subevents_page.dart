import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/pages/create_subevent_page.dart';
import 'package:wilson_campus_scene/pages/subevent_page.dart';
import 'package:wilson_campus_scene/services/subeventstore.dart';
import 'package:wilson_campus_scene/services/user.dart';

class SubEventsPage extends StatefulWidget {
  final String eventID;
  const SubEventsPage({super.key, required this.eventID});

  @override
  State<SubEventsPage> createState() => _SubEventsPageState();
}

class _SubEventsPageState extends State<SubEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<SubEvent?>>(
          stream: SubEventStoreService().getAll(widget.eventID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return snapshot.data!.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                          decoration: const BoxDecoration(
                              border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          )),
                          child: ListTile(
                              trailing: const Icon(Icons.chevron_right),
                              title: Text(
                                snapshot.data![index]!.title!,
                              ),
                              titleTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 24,
                              ),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SubEventPage(
                                      id: snapshot.data![index]!.id!);
                                }));
                              }));
                    })
                : const Center(child: Text('No Sub Events found'));
          }),
      floatingActionButton: StreamBuilder<WilsonUser?>(
          stream: WilsonUserStoreService()
              .get(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, u) {
            if (u.data?.role == WilsonUserRole.admin) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CreateSubEventPage(
                      eventID: widget.eventID,
                    );
                  }));
                },
                backgroundColor: Colors.black,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              );
            }
            return SizedBox();
          }),
    );
  }
}
