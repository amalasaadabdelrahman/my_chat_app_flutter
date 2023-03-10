import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsSecreen extends StatelessWidget {
  static const id = 'notificationSecreen';
  const NotificationsSecreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<RemoteNotification?> notifications =
        ModalRoute.of(context)!.settings.arguments as List<RemoteNotification?>;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text('There is no notifications'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                if (notifications[index] != null) {
                  return ListTile(
                      title: Text('${notifications[index]?.title}'),
                      subtitle: Text('${notifications[index]?.body}'));
                }
                return SizedBox();
              },
            ),
    );
  }
}
