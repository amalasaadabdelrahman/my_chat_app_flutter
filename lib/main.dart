import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/Secreens/Notifications_Secreen.dart';
import 'package:my_chat_app/Secreens/sing_in_secreen.dart';
import 'package:my_chat_app/Secreens/welcome_secreen.dart';
import 'Secreens/chat_secreen.dart';
import 'Secreens/registration_secreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

String? fcmToken;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification!.title}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.subscribeToTopic("braking_news");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _auth = FirebaseAuth.instance;
  void getFCM() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print('Fcm token : $fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    getFCM();

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
        NotificationsSecreen.id: (context) => NotificationsSecreen(),
      },
    );
  }
}
