import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String profileImage;
  final String username;
  const ProfileScreen(
      {super.key, required this.profileImage, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 25),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                ),
                SizedBox(
                  height: 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Username',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '""',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '""',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
