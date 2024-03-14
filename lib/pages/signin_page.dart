import 'package:chat_app/auth_services.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfiled.dart';
import 'package:chat_app/pages/image_picker.dart';
import 'package:chat_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SigninPage extends StatefulWidget {
  final void Function()? onTap;

  const SigninPage({super.key, required this.onTap});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final controller = Get.put(ImagePickerController());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  bool isLoading = false;
  String imgUrl = '';
  void signIn() async {
    setState(() {
      isLoading = true;
    });
  }

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      Utils.toastMessage('Passwords do not match');
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailandPassword(emailController.text,
          passwordController.text, usernameController.text, imgUrl);
    } catch (e) {
      Utils.toastMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Obx(() {
                    return InkWell(
                      onTap: () {
                        controller.pickImage();
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[
                            200], // Optional: Set a background color for the circle
                        child: ClipOval(
                          child: controller.image.value == null ||
                                  controller.image.value!.path == ''
                              ? const Icon(Icons.camera)
                              : AspectRatio(
                                  aspectRatio:
                                      1.0, // Ensure a square aspect ratio
                                  child: Image.file(
                                    controller.image.value!,
                                    fit: BoxFit
                                        .cover, // Cover the entire square area
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                  // Obx(() {
                  //   return Image.network(controller.networkImage.value);
                  // }),
                  const SizedBox(height: 30),
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                      onTap: () async {
                        imgUrl = await controller.uploadImageToFirebase();
                        signUp();
                      },
                      isLoading: isLoading,
                      text: 'Sign Up'),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Log In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
