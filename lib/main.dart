import 'package:blackholeapp/circle.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:blackholeapp/start_view.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterCreate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BubbleEffect'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
                color: Colors.white, fontFamily: 'Nunito', letterSpacing: 1.0),
          ),
        ),
        body: CanvasCircle()
    );
  }
}

class CanvasCircle extends StatefulWidget {
  final Widget child;

  CanvasCircle({Key key, this.child}) : super(key: key);

  @override
  _CanvasCircleState createState() => _CanvasCircleState();
}

class _CanvasCircleState extends State<CanvasCircle> {
  double percentage;

  @override
  void initState() {
    super.initState();
    setState(() {
      percentage = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RunBallPage();
    // return Container(
    //   child: CustomPaint(
    //      painter: CordView(context),
    //   ),
    // );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  MyPainter({
    this.lineColor,
    this.completeColor,
    this.completePercent,
    this.width
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
        ..color = lineColor
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center  = new Offset(size.width/2, size.height/2);
    double radius  = min(size.width/2,size.height/2);
    canvas.drawCircle(
        center,
        radius,
        line
    );
    double arcAngle = 2 * pi * (completePercent/100);
    canvas.drawArc(
        new Rect.fromCircle(center: center,radius: radius),
         -pi/2,
        arcAngle,
        false,
        complete
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
} 