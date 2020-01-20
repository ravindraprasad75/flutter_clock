import 'package:flutter/material.dart';

class DateTimeView extends StatelessWidget {
  final String hour;
  final String minute;
  final String day;

  DateTimeView({
    @required this.hour,
    @required this.minute,
    @required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      bottom: 10,
      child: Container(
        width: MediaQuery.of(context).size.width / 8,
        height: MediaQuery.of(context).size.width / 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: FittedBox(
                child: Row(
                  children: <Widget>[
                    Text(hour),
                    Text(':'),
                    Text(minute),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: FittedBox(child: Text(day)),
            )
          ],
        ),
      ),
    );
  }
}
