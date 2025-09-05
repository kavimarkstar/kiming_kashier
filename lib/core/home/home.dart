import 'package:flutter/material.dart';
import 'package:kiming_kashier/core/view/bottom/bottom.dart';
import 'package:kiming_kashier/core/view/keyboard/keyboard.dart';
import 'package:kiming_kashier/core/view/middle/middle.dart';
import 'package:kiming_kashier/core/view/top/top.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> with TickerProviderStateMixin {
  bool isShow = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start with keyboard visible
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showBottom() {
    setState(() {
      isShow = !isShow;
    });

    if (isShow) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff151515),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                hedderbuild(context, showBottom),
                middlebuild(context),
                bottombuild(context, isShow),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.3 *
                    _slideAnimation.value,
                height: MediaQuery.of(context).size.height,
                child: _slideAnimation.value > 0
                    ? Opacity(opacity: _slideAnimation.value, child: Keyboard())
                    : SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}
