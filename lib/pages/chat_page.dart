// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/my_textfiled.dart';
import 'package:chat_app/pages/image_picker.dart';
import 'package:chat_app/services/auth/chat/chat_services.dart';
import 'package:chat_app/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverUsername;
  final String receiverProfileImage;
  final String receiverToken;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUsername,
    required this.receiverUserID,
    required this.receiverProfileImage,
    required this.receiverToken,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  NotificationServices notificationServices = NotificationServices();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final ScrollController _scrollController = ScrollController();
  final ImagePickerController _imagePickerController = ImagePickerController();

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void sendMessage(String message, {String? imageUrl}) async {
    try {
      notificationServices.getDeviceToken().then((value) async {
        var data = {
          'to': widget.receiverToken,
          'priority': 'high',
          'notification': {
            'title': widget.receiverUsername,
            'body': message,
          },
          'data': {
            'type': 'message',
            'id': '123456',
          }
        };
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(data),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAxSMzB_4:APA91bFWGc1gMzOeMkgi2-RX4JjwlzjnhTIfRCqG-q9DseYg9qkorTtRTveJq_MUVn03eM7efj5AYWF5UhuU2c0WGNS-gAKx9isFUG3Qo6rJr3h7k2W4vG109UTiAvAtMdAUttB-9zKL'
            });
      });
      if (message.isEmpty && imageUrl != null) {
        notificationServices.showNotification(
          'New Message from ${widget.receiverUsername}',
          message,
        );
        await _chatService.sendMessage(
            receiverId: widget.receiverUserID, message: '', imageUrl: imageUrl);
        _messageController.clear();
        scrollToBottom();
      } else {
        await _chatService.sendMessage(
            receiverId: widget.receiverUserID, message: message, imageUrl: '');
        _messageController.clear();
        scrollToBottom();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 4, 181, 204),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverProfileImage),
              radius: 22,
            ),
            const SizedBox(width: 10),
            Text(
              widget.receiverUsername,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserID,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var backgroundColor = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.green
        : Colors.grey;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            GestureDetector(
              onTap: () {
                if (data['image'] != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(),
                        body: Center(
                          child: PhotoView(
                            imageProvider: NetworkImage(data['image']),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ChatBubble(
                  message: data['message'],
                  imageUrl: data['image'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openMediaDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose'),
          content: Builder(
            builder: (BuildContext context) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () async {
                      setState(() {
                        Navigator.pop(context);
                      });
                      await _imagePickerController.pickImageCamera();
                      if (_imagePickerController.image.value != null) {
                        String imageUrl = await _imagePickerController
                            .uploadImageToFirebase();
                        sendMessage('', imageUrl: imageUrl);
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      size: 30,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        Navigator.pop(context);
                      });
                      await _imagePickerController.pickImage();
                      if (_imagePickerController.image.value != null) {
                        String imageUrl = await _imagePickerController
                            .uploadImageToFirebase();
                        sendMessage('', imageUrl: imageUrl);
                      }
                    },
                    child: const Icon(
                      Icons.collections,
                      size: 30,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
            controller: _messageController,
            hintText: 'Enter Message',
            obscureText: false,
          ),
        ),
        IconButton(
          onPressed: () {
            openMediaDialog();
          },
          icon: const Icon(
            Icons.add_a_photo,
            size: 40,
          ),
        ),
        IconButton(
          onPressed: () {
            sendMessage(_messageController.text);
          },
          icon: const Icon(
            Icons.send_rounded,
            size: 40,
          ),
        )
      ],
    );
  }
}
