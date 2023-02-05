import 'package:flutter/material.dart';
import 'package:my_chat_app/Secreens/sing_in_secreen.dart';
import 'package:my_chat_app/Secreens/welcome_secreen.dart';

import 'Secreens/chat_secreen.dart';
import 'Secreens/registration_secreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _auth = FirebaseAuth.instance;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MessageMe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute:
          _auth.currentUser != null ? ChatSecreen.id : WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegistrationSecreen.id: (context) => RegistrationSecreen(),
        SingInSecrren.id: (context) => SingInSecrren(),
        ChatSecreen.id: (context) => ChatSecreen(),
      },
    );
  }
}
