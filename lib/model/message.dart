import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String imageUrl;
  Message(
      {required this.senderId,
      required this.senderEmail,
      required this.receiverId,
      required this.timestamp,
      required this.message,
      required this.imageUrl});
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'image': imageUrl,
      'timestamp': timestamp
    };
  }
}
