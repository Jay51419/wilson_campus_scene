import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/pages/create_event_page.dart';
import 'package:wilson_campus_scene/pages/create_user_info_page.dart';
import 'package:wilson_campus_scene/pages/event_page.dart';
import 'package:wilson_campus_scene/services/eventstore.dart';
import 'package:wilson_campus_scene/services/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final eventstoreService = EventstoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final WilsonUserStoreService userStoreService = WilsonUserStoreService();
  WilsonUser? user;
  void checkUserInfo(context) async {
    var u = await WilsonUserStoreService()
        .get(FirebaseAuth.instance.currentUser!.uid)
        .first;
    if (u?.department == null || u?.year == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateUserInfoPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkUserInfo(context);
    return SafeArea(
      top: true,
      child: Scaffold(
        body: StreamBuilder(
          stream: eventstoreService.getAll(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data.isEmpty) {
              return const Center(child: Text('No Events found'));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: const BoxDecoration(
                      border: Border(
                    bottom: BorderSide(color: Colors.grey),
                  )),
                  child: ListTile(
                    trailing: const Icon(Icons.chevron_right),
                    title: Text(
                      snapshot.data[index].title,
                    ),
                    titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24,
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EventPage(id: snapshot.data[index].id);
                      }));
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: StreamBuilder<WilsonUser?>(
            stream: userStoreService.get(auth.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.data?.role == WilsonUserRole.admin) {
                return FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const CreateEventPage();
                    }));
                  },
                  backgroundColor: Colors.black,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                );
              }
              return const SizedBox();
            }),
      ),
    );
  }
}
