# analog_clock_for_flutter

Beautiful flutter analog clocks

## Screenshots
![clocks.gif](clocks.gif)
## Usage
To use plugin, just import package `import 'package:analog_clock_for_flutter/analog_clock.dart';`

## Example
You can check example directory to know how to use it.
```dart
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
```
## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
