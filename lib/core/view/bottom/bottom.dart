import 'package:flutter/material.dart';

@override
Widget bottombuild(BuildContext context, bool isShow) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(5, 2.5, 5, 5),
    child: Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(width: 0.1, color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (!isShow) SizedBox(width: 60),
          AnimatedOpacity(
            opacity: !isShow ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: !isShow
                        ? MediaQuery.of(context).size.width * 0.15
                        : 0,
                    height: !isShow
                        ? MediaQuery.of(context).size.height * 0.15
                        : 0,
                    child: !isShow
                        ? Image.asset('assets/images/logo.png')
                        : SizedBox.shrink(),
                  ),
                  !isShow
                      ? Text(
                          'KaptureX',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
          if (!isShow) SizedBox(width: 60),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      cursorColor: Colors.blueAccent,
                      decoration: InputDecoration(
                        filled: true,
                        hint: Text(
                          'Enter Barcode',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        helperStyle: TextStyle(color: Colors.white70),
                        fillColor: const Color.fromARGB(
                          255,
                          102,
                          102,
                          102,
                        ).withOpacity(0.05),

                        hintStyle: TextStyle(color: Colors.white70),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),

          Container(
            margin: const EdgeInsets.all(2),
            width: MediaQuery.of(context).size.width * 0.25,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildamountbutton(context, 'TOTAL'),
                buildamountbutton(context, 'Pieces'),
                buildamountbutton(context, 'Discount'),
                buildamountbutton(context, 'Add'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

@override
Widget buildamountbutton(BuildContext context, String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 3),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.15,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ],
  );
}
