import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String? message;
  final String? imageUrl;

  const ChatBubble({
    Key? key, // Added Key parameter
    required this.imageUrl,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: 150,
              height: 150,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    backgroundColor: Colors.white,
                    strokeWidth: 3,
                  );
                }
              },
            )
          : Text(
              message!,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
    );
  }
}
