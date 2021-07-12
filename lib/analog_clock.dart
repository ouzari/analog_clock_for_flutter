import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:swipe_gesture_recognizer/swipe_gesture_recognizer.dart';

class Clock {
  //String image;
  ui.Image image;
  Color handsColor;
  Clock(this.image, this.handsColor);
}

class FlutterAnalogClock extends StatefulWidget {
  final DateTime dateTime;
  final double borderWidth;
  final double width;
  final double height;
  final BoxDecoration decoration;
  final Widget child;

  const FlutterAnalogClock(
      {this.dateTime,
      this.borderWidth = 0,
      this.width = 300,
      this.height = 300,
      this.decoration = const BoxDecoration(),
      this.child,
      Key key})
      : super(key: key);

  @override
  _FlutterAnalogClockState createState() =>
      _FlutterAnalogClockState(this.dateTime);
}

Future<ui.Image> getUiImage(
    String imageAssetPath, int height, int width) async {
  final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
  image.Image baseSizeImage =
      image.decodeImage(assetImageByteData.buffer.asUint8List());
  image.Image resizeImage =
      image.copyResize(baseSizeImage, height: height, width: width);
  ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

class _FlutterAnalogClockState extends State<FlutterAnalogClock> {
  Timer _timer;
  DateTime _dateTime;
  _FlutterAnalogClockState(this._dateTime);
  ui.Image watchBackground;
  List<Clock> clocks = [];
  int clockIndex = 0;
  @override
  void initState() {
    super.initState();
    this._dateTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _dateTime = _dateTime?.add(Duration(seconds: 1));
      if (mounted) {
        setState(() {});
      }
    });
    getClocks().then((value) => getImage());
  }

  Future<void> getClocks() async {
    clocks = [
      Clock(
          await getUiImage("assets/watches/clockBackground01.png",
              widget.height.toInt(), widget.width.toInt()),
          Colors.black),
      Clock(
          await getUiImage("assets/watches/clockBackground02.png",
              widget.height.toInt(), widget.width.toInt()),
          Colors.brown),
      Clock(
          await getUiImage("assets/watches/clockBackground03.png",
              widget.height.toInt(), widget.width.toInt()),
          Colors.blue),
      Clock(
          await getUiImage("assets/watches/clockBackground04.png",
              widget.height.toInt(), widget.width.toInt()),
          Colors.amberAccent),
      Clock(
          await getUiImage("assets/watches/clockBackground05.png",
              widget.height.toInt(), widget.width.toInt()),
          Colors.black)
    ];
  }

  void getImage() async {
    setState(() {
      watchBackground = clocks[clockIndex].image;
    });
  }
  /*void getImage(double h, double w) async {
    watchBackground = await getUiImage(
        "assets/watches/" + clocks[clockIndex].image, h.toInt(), w.toInt());
  }*/

  void swipeClock(bool left) {
    if (left)
      clockIndex = (clockIndex + 1) % clocks.length;
    else {
      clockIndex = clockIndex - 1;
      if (clockIndex < 0) clockIndex = clocks.length - 1;
    }

    getImage();
    print(clockIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: widget.decoration,
      child: SwipeGestureRecognizer(
        onSwipeLeft: () {
          swipeClock(true);
        },
        onSwipeRight: () {
          swipeClock(false);
        },
        child: clocks.length > 0
            ? CustomPaint(
                child: widget.child,
                painter: FlutterAnalogClockPainter(_dateTime ?? DateTime.now(),
                    borderWidth: widget.borderWidth,
                    watchBackground: watchBackground,
                    watchIndex: clockIndex,
                    handsColor: clocks[clockIndex].handsColor),
              )
            : Container(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class FlutterAnalogClockPainter extends CustomPainter {
  final DateTime _datetime;
  double _borderWidth;
  final ui.Image watchBackground;
  int watchIndex;
  Color handsColor;
  FlutterAnalogClockPainter(this._datetime,
      {double borderWidth,
      this.watchBackground,
      this.watchIndex,
      this.handsColor})
      : _borderWidth = borderWidth;

  @override
  void paint(Canvas canvas, Size size) async {
    final radius = min(size.width, size.height) / 2;
    final double borderWidth = _borderWidth ?? radius / 20.0;
    canvas.drawImage(watchBackground, Offset.zero, Paint());
    canvas.translate(size.width / 2, size.height / 2);

    /* canvas.drawCircle(
        Offset(0, 0),
        radius,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white);*/

    // border style
    if (borderWidth > 0) {
      Paint borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true;
      canvas.drawCircle(Offset(0, 0), radius - borderWidth / 2, borderPaint);
    }
    double L = 150;
    double S = 6;
    _paintHourHand(canvas, L / 2.0, S);
    _paintMinuteHand(canvas, L / 1.4, S / 1.4);
    _paintSecondHand(canvas, L / 1.2, S / 3);

    //drawing center point
    Paint centerPointPaint = Paint()
      ..strokeWidth = ((radius - borderWidth) / 10)
      ..strokeCap = StrokeCap.round
      ..color = handsColor;
    canvas.drawPoints(ui.PointMode.points, [Offset(0, 0)], centerPointPaint);
  }

  /// drawing hour hand
  void _paintHourHand(Canvas canvas, double radius, double strokeWidth) {
    double angle = _datetime.hour % 12 + _datetime.minute / 60.0 - 3;
    Offset handOffset = Offset(cos(getRadians(angle * 30)) * radius,
        sin(getRadians(angle * 30)) * radius);
    final hourHandPaint = Paint()
      ..color = handsColor
      ..strokeWidth = strokeWidth;
    canvas.drawLine(Offset(0, 0), handOffset, hourHandPaint);
  }

  /// drawing minute hand
  void _paintMinuteHand(Canvas canvas, double radius, double strokeWidth) {
    double angle = _datetime.minute - 15.0;
    Offset handOffset = Offset(cos(getRadians(angle * 6.0)) * radius,
        sin(getRadians(angle * 6.0)) * radius);
    final hourHandPaint = Paint()
      ..color = handsColor
      ..strokeWidth = strokeWidth;
    canvas.drawLine(Offset(0, 0), handOffset, hourHandPaint);
  }

  /// drawing second hand
  void _paintSecondHand(Canvas canvas, double radius, double strokeWidth) {
    double angle = _datetime.second - 15.0;
    Offset handOffset = Offset(cos(getRadians(angle * 6.0)) * radius,
        sin(getRadians(angle * 6.0)) * radius);
    final hourHandPaint = Paint()
      ..color = handsColor
      ..strokeWidth = strokeWidth;
    canvas.drawLine(Offset(0, 0), handOffset, hourHandPaint);
  }

  @override
  bool shouldRepaint(FlutterAnalogClockPainter oldDelegate) {
    return _datetime != oldDelegate._datetime ||
        _borderWidth != oldDelegate._borderWidth ||
        watchIndex != oldDelegate.watchIndex;
  }

  static double getRadians(double angle) {
    return angle * pi / 180;
  }
}
