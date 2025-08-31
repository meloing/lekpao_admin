import 'package:flutter_tex/flutter_tex.dart';

import 'nav_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await TeXRenderingServer.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Le Kpao',
        theme: ThemeData(
          primarySwatch: Colors.blue
        ),
        home: const NavScreen(uid: "archetechnology1011@gmail.com"),
        debugShowCheckedModeBanner: false
    );
  }
}