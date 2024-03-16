import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/pages/user_applications_page.dart';
import 'package:wilson_campus_scene/pages/user_participantions_page.dart';
import 'package:wilson_campus_scene/services/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
          body: StreamBuilder<WilsonUser?>(
              stream: WilsonUserStoreService()
                  .get(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == null) {
                  return const Center(child: Text('No User found'));
                }
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        snapshot.data!.name!,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(snapshot.data!.email!),
                      trailing: IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                        title: const Text('Department'),
                        trailing: Text(snapshot.data!.department ?? "")),
                    const Divider(),
                    ListTile(
                        title: const Text('Year'),
                        trailing: Text(snapshot.data!.year ?? "")),
                    const Divider(),
                    ListTile(
                      title: const Text('Applications'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const UserApplicationsPage();
                        }));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Participations'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const UserParticipantsPage();
                        }));
                      },
                    ),
                    const Divider(),
                  ],
                ));
              })),
    );
  }
}
