import 'package:analog_clock_for_flutter/analog_clock.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Clock demo'),
          ),
          body:
              Center(child: SizedBox(child: FlutterAnalogClock(radius: 400)))),
    );
  }
}
