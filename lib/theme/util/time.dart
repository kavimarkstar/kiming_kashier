// ignore_for_file: use_super_parameters

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kiming_kashier/core/view/top/widget/detaile_view.dart';

class Time extends StatefulWidget {
  const Time({Key? key}) : super(key: key);

  @override
  _TimeState createState() => _TimeState();
}

class _TimeState extends State<Time> {
  late Timer _Timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _Timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _Timer = Timer.periodic(Duration(seconds: 1), (Timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return detaileViewbuild(context, _formatTime(_currentTime));
  }
}
