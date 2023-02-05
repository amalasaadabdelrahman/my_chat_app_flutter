import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/Secreens/registration_secreen.dart';
import 'package:my_chat_app/Secreens/sing_in_secreen.dart';

import '../component/my_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_secreen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    height: 180,
                    child: Image.asset('images/message-icon-png-17.png'),
                  ),
                  Text(
                    'MessageMe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            MyButton(
              color: Colors.blue,
              title: 'Sing in ',
              onpressed: () {
                Navigator.pushNamed(context, SingInSecrren.id);
              },
            ),
            MyButton(
              color: Colors.blue,
              title: 'register ',
              onpressed: () {
                Navigator.pushNamed(context, RegistrationSecreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
