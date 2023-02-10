import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:my_chat_app/Secreens/sing_in_secreen.dart';
import 'package:my_chat_app/main.dart';
import 'Notifications_Secreen.dart';
import 'package:http/http.dart' as http;

final _fireStore = FirebaseFirestore.instance;
late User singInUser;

class ChatSecreen extends StatefulWidget {
  static const id = 'chat_secreen';
  const ChatSecreen({Key? key}) : super(key: key);

  @override
  State<ChatSecreen> createState() => _ChatSecreenState();
}

class _ChatSecreenState extends State<ChatSecreen> {
  final _auth = FirebaseAuth.instance; //
  String? message;
  String token = '';
  final messageTextController = TextEditingController();
  List<RemoteNotification?> notifications = [];
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        singInUser = user;
        print(singInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        setState(() {
          notifications.add(message.notification);
        });
        print(
            'Message also contained a notification: ${message.notification!.title} ');
      }
    });
  }

  void sentNotifications(String title, String body) async {
    http.Response response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/messageme-app-8c7c9/messages:send'),
      headers: {
        'content_Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(
        {
          "message": {
            // "topic": "ChatApp", //--> topic not support spaces
            "token": fcmToken,
            "notification": {"title": title, "body": body},
          }
        },
      ),
    );
    print('response.body : ${response.body}');
  }

  Future<AccessToken> getAcseseToken() async {
    final servicAcount = await rootBundle.loadString(
        'asset/messageme-app-8c7c9-firebase-adminsdk-1kb47-431fd539dd.json');
    final data = await json.decode(servicAcount);
    print(data);
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": data['private_key_id'],
      "private_key": data['private_key'],
      "client_email": data['client_email'],
      "client_id": data['client_id'],
      "type": data['type']
    });
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final AuthClient authClient =
        await clientViaServiceAccount(accountCredentials, scopes)
          ..close();
    print(authClient.credentials.accessToken);
    return authClient.credentials.accessToken;
  }

  @override
  void initState() {
    getCurrentUser();
    getAcseseToken().then((value) => token = value.data);
    getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Image.asset(
              'images/message-icon-png-17.png',
              height: 35,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'MessageMe',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                iconSize: 25,
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, NotificationsSecreen.id,
                          arguments: notifications)
                      .then(
                    (value) => setState(() {
                      notifications.clear();
                    }),
                  );
                },
              ),
              notifications.isNotEmpty
                  ? Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '${notifications.length}',
                        style: TextStyle(fontSize: 10),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          IconButton(
            iconSize: 25,
            icon: Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, SingInSecrren.id, (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStreamBuilder(),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) async {
                        message = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'text': message,
                        'sender': singInUser.email,
                        'time': DateTime.now()
                      });
                      sentNotifications(
                          'message from ${singInUser.email}', '$message');
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageLine extends StatelessWidget {
  const MessageLine({Key? key, this.sender, this.text, required this.isMe})
      : super(key: key);
  final String? sender;
  final String? text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          Material(
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            color: isMe ? Colors.blue : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: isMe
                  ? Text(
                      '$text',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    )
                  : Text(
                      '$text',
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          List<MessageLine> messageWidgets = [];
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }
          final messages = snapshot.data!.docs.reversed;
          for (var messages in messages) {
            final messageText = messages.get('text');
            final messageSender = messages.get('sender');
            final currentUser = singInUser.email;
            final messageWidget = MessageLine(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender,
            );
            messageWidgets.add(messageWidget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageWidgets,
            ),
          );
        });
  }
}
