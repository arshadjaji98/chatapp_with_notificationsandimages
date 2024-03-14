import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final bool isLoading; // New parameter to track loading state

  const MyButton(
      {Key? key,
      required this.onTap,
      required this.text,
      required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // Disable onTap when isLoading is true
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: isLoading
              ? Colors.grey
              : Colors.black, // Change color when loading
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator() // Show loading indicator when isLoading is true
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
