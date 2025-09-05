import 'package:flutter/material.dart';
import 'package:kiming_kashier/core/view/top/widget/detaile_view.dart';
import 'package:kiming_kashier/core/view/top/widget/network.dart';

@override
Widget hedderbuild(BuildContext context, VoidCallback isShowButton) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(5, 5, 5, 2.5),
    child: Container(
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(width: 0.1, color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ! Detaile Display String
                  detaileViewbuild(context, ""),
                  detaileViewbuild(context, ""),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ! Detaile Display String
                  detaileViewbuild(context, "Location"),
                  detaileViewbuild(context, "KaviMark"),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ! Detaile Display String
                  detaileViewbuild(context, "0000012"),
                  detaileViewbuild(context, "Unit 8"),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ! Detaile Display String
                  detaileViewbuild(context, "08/21/2025"),
                  detaileViewbuild(context, "11:08:49"),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [NetworkWidget(isShowButton: isShowButton)],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
