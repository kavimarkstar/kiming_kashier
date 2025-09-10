import 'package:flutter/material.dart';

@override
Widget detaileViewbuild(BuildContext context, String title) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black,
      border: Border.all(width: 1, color: Colors.white.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(500),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
