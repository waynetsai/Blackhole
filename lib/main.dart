
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterCreate',
      home: M(),
      debugShowCheckedModeBanner: false,
    );
  }
}
double gDist(dX, dY) => sqrt(pow(dX, 2) + pow(dY, 2));

class M extends StatefulWidget {
  @override
  _MState createState() => _MState();
}

class _MState extends State<M>
    with SingleTickerProviderStateMixin {

  AnimationController _co;
  Offset mPos;
  double cOY;
  double cW;
  double cH;
  List<Ball> bList = [];
  @override
  void initState() {
    super.initState();
    _co = AnimationController(
        duration: Duration(milliseconds: (1000 ~/60).toInt()), vsync: this)
    ..addListener(() => setState(() => loop()))
    ..addStatusListener((_s) {
      if (_s == AnimationStatus.completed) {
        _co.reverse();
      } else if (_s == AnimationStatus.dismissed) {
        _co.forward();
      }
    })
    ..forward();
  }

  @override
  void dispose() {
    super.dispose();
    _co.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Bubble Effect",
            style: TextStyle(
                color: Colors.white, fontFamily: 'Nunito', letterSpacing: 1.0),
          ),
        ),
      body: GestureDetector(
        onPanStart: (DragStartDetails _d) {
          var pos = _d.globalPosition;
          mPos = Offset(
              pos.dx, pos.dy - cOY);
          _onTouch(mPos);
        },
        child: LayoutBuilder(builder: (context, constraint) {
          cOY = MediaQuery.of(context).size.height - constraint.maxHeight;
          cH = constraint.maxHeight;
          cW = MediaQuery.of(context).size.width;
          return Container(
            height: cH,
            width: cW,
            color: Colors.grey,
            child: CustomPaint(
              painter: BubbleChart(bList),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          this.init();
        },
        tooltip: 'start',
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  _onTouch(Offset mPos) {
    double dx = mPos.dx;
    double dy = mPos.dy;
    bList.forEach((_b) {
      if (sqrt(pow(dx - _b.x, 2) + pow(dy - _b.y, 2)) < _b.r) {
        _b.color = Colors.lightBlue;
        _b.t = "click!";
      }
    });
  }

  init() {
    if (bList.length == 0) bList.add(Ball(x: cW / 2, y: cH / 2, color: Colors.blue,t: "News (0)", r: 60, vX: 2, vY: 0),);
    var co = 0;
    while(bList.length < 10) {
      var _f = true;
      var x = Random().nextInt(cW.toInt());
      var y = Random().nextInt(cH.toInt());
      this.bList.forEach((_b) => ( gDist(x - _b.x, y -_b.y) < _b.r * 2 )? _f = false : _f = _f);
      if(_f) {
        this.bList.add(Ball(x: x.toDouble(), y: y.toDouble(), color: Colors.blue,t: "News ($co)", r: 60, vX: 2, vY: 0),);
        co++;
      }
    }
  }

  void loop() {
    this.bList.forEach((_i) {
        var dX = _i.x - cW / 2;
        var dY = _i.y - cH / 2 - cOY;
        var d = pow(dX, 2) + pow(dY, 2);
        if ( d >= (pow(_i.r, 2) - 3600) ) {
          _i.vX = dX / 200;
          _i.vY = dY / 200;
          _i.x -= _i.vX ;
          _i.y -= _i.vY ;
          this.bList.forEach((_j) {
            var _dx = _i.x - _j.x;
            var _dy = _i.y - _j.y;
            if(_i == _j) return;
            if(gDist(_dx, _dy) <= _i.r *2 + 10) {
              var s = 1/150;
              _i.x += _dx * s;
              _i.y += _dy * s;
              _j.x -= _dx * s;
              _j.y -= _dy * s;
            }
          });
        }
    });
  }
}
class BubbleChart extends CustomPainter {
  Paint bP;
  List<Ball> bList;
  BubbleChart(this.bList);
  @override
  void paint(Canvas canvas, Size size) {
    bList.forEach((o) {
      draw(canvas, o.x, o.y, o.r, o.t, o.color);
    });
  }

  draw(_c, _dx, _dy, _r, _text, _color) {
    bP = Paint()..color = _color;
    _c.drawCircle(Offset(_dx, _dy), _r, bP);
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 25.0,
        maxLines: 3,
      ),
    )..addText(_text);
    _c.drawParagraph(
        paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: 65.0)),
        Offset(_dx - _r / 2, _dy - _r / 2));
  }

   @override
  bool shouldRepaint(BubbleChart oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BubbleChart oldDelegate) => false;
}

class Ball {
  double vX; 
  double vY;
  double x;
  double y; 
  String t;
  Color color;
  double r;
  Ball({this.x, this.y, this.color, this.r, this.vX, this.vY, this.t});
}


