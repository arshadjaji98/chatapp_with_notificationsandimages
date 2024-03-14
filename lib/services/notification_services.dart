import 'dart:io';
import 'dart:math';
import 'package:chat_app/pages/chat_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provissional permissions');
    } else {
      print('user denied permissions');
    }
  }

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidIntializationSetting =
        const AndroidInitializationSettings('@mipmap/ic_launcher.png');
    var intialiazationSetting = InitializationSettings(
      android: androidIntializationSetting,
    );
    await _flutterLocalNotificationsPlugin.initialize(intialiazationSetting,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
      } else {}
    });
  }

  Future<void> showNotification(String title, String body) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'High Importance Notification',
      importance: Importance.high,
    );
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'your channel discription',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Ticker',
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefereshed() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Refereshed');
    });
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? intitialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (intitialMessage != null) {
      handleMessage(context, intitialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'message') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ChatPage(
                    receiverUserEmail: 'receiverUserEmail',
                    receiverUsername: 'receiverUsername',
                    receiverUserID: 'receiverUserID',
                    receiverProfileImage: 'receiverProfileImage',
                    receiverToken: 'token',
                  )));
    }
  }
}
