import 'package:drawer_firebse_dec/view/home_screen/home_screen.dart';
import 'package:drawer_firebse_dec/view/login_screen/login_screen.dart';
import 'package:drawer_firebse_dec/view/splash_screen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBXnmJYudtG_xsToCIcCtWx8hBiPCD8MhE",
          appId: "1:1025777796893:android:3c8ff11fea40dd0df903f4",
          messagingSenderId: "",
          projectId: "dec-sample",
          storageBucket: "dec-sample.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SplashScreen(isLogged: true);
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}
