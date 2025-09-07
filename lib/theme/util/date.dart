// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:kiming_kashier/core/view/top/widget/detaile_view.dart';

class Date extends StatefulWidget {
  const Date({super.key});

  @override
  _DateState createState() => _DateState();
}

class _DateState extends State<Date> {
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _upDateDate();
  }

  void _upDateDate() {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  String _formatDate(DateTime DateTime) {
    return '${DateTime.day.toString().padLeft(2, '0')}/${DateTime.month.toString().padLeft(2, '0')}/${DateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return detaileViewbuild(context, _formatDate(_currentDate));
  }
}
