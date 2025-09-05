import 'package:flutter/material.dart';

@override
Widget middlebuild(BuildContext context) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(5, 2.5, 5, 2.5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: double.infinity,
      ),
    ),
  );
}
