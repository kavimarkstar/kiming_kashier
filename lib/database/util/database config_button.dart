import 'package:flutter/material.dart';

class DatabaseConfigButton extends StatefulWidget {
  final VoidCallback onPressed;
  const DatabaseConfigButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  _DatabaseConfigButtonState createState() => _DatabaseConfigButtonState();
}

class _DatabaseConfigButtonState extends State<DatabaseConfigButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0),
      onPressed: widget.onPressed,
      // data base icon
      icon: Icon(Icons.wifi_tethering),
    );
  }
}
