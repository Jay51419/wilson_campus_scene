import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/firebase_options.dart';

import 'package:wilson_campus_scene/pages/home_page.dart';
import 'package:wilson_campus_scene/pages/profile_page.dart';
import 'package:wilson_campus_scene/pages/signin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  int _selectedIndex = 0;

  List<Widget> tabItems = [
    const HomePage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return Scaffold(
                body: tabItems[_selectedIndex],
                bottomNavigationBar: FlashyTabBar(
                  animationCurve: Curves.linear,
                  selectedIndex: _selectedIndex,
                  iconSize: 30,
                  showElevation: false, // use this to remove appBar's elevation
                  onItemSelected: (index) => setState(() {
                    _selectedIndex = index;
                  }),
                  items: [
                    FlashyTabBarItem(
                      icon: const Icon(Icons.event),
                      title: const Text('Events'),
                    ),
                    FlashyTabBarItem(
                      icon: const Icon(Icons.person),
                      title: const Text('Profile'),
                    ),
                  ],
                ),
              );
            } else {
              return const SignInPage();
            }
          },
        ),
      ),
    );
  }
}
