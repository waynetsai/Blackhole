import 'dart:math';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';

double getDistance(dX, dY) => sqrt(pow(dX, 2) + pow(dY, 2));

class RunBallPage extends StatefulWidget {
  @override
  _RunBallPageState createState() => _RunBallPageState();
}

class _RunBallPageState extends State<RunBallPage>
    with SingleTickerProviderStateMixin {

  AnimationController controller;
  bool isValidTouch = false;
  Offset mousePos;
  Offset get centerPos => Offset( canvasHeight / 2, canvasHeight / 2 + canvasOffsetY);
  double canvasOffsetY;
  double canvasWidth;
  double canvasHeight;
  double curveValue;
  Animation<double> animation;
  CurvedAnimation curve;
  List<Ball> bubbleList = [
    // Ball(x: 60, y: 60, color: Colors.blue,t: "測試1", r: 60, aX: 0, aY: 0, vX: 2, vY: 0),
    // Ball(x: 360, y: 60, color: Colors.pink, t: "測試2", r: 60, aX: 0, aY: 0, vX: 2, vY: 0),
    // Ball(x: 200, y: 200, color: Colors.teal, t: "測試3", r: 60, aX: 0, aY: 0, vX: 0, vY: 2),
    // Ball(x: 300, y: 300, color: Colors.yellow, t: "測試4", r: 60, aX: 0, aY: 0, vX: 0, vY: 2),
    // Ball(x: 60, y: 300, color: Colors.cyan, t: "測試5", r: 60, aX: 0, aY: 0, vX: 0, vY: 2),
    
    // Ball(x: 200, y: 380, color: Colors.blue, t: "測試文字1", r: 60, aX: 0, aY: 0, vX: 2, vY: 0),
    // Ball(x: 200, y: 380, color: Colors.purple, t: "測試文字2", r: 60, aX: 0, aY: 0, vX: 2, vY: 0),
    // Ball(x: 200, y: 380, color: Colors.teal, t: "測試文字3", r: 60, aX: 0, aY: 0, vX: 2, vY: 0),
    // Ball(x: 200, y: 380, color: Colors.yellow, t: "測試文字4", r: 60, aX: 0, aY: 0, vX: 2, vY: 0),
    // Ball(x: 200, y: 380, color: Colors.cyan, t: "測試文字5", r: 60, aX: 0, aY: 0, vX: 2, vY: 0),
  ];


  Timer _timer;
  @override
  void initState() {
    super.initState();
  // _timer = Timer.periodic(Duration(milliseconds: (1000 ~/6).toInt()), (timer) {
  //   updateCanvas(); 
  // });
    controller = AnimationController(
        // upperBound: 0.05,
        duration: Duration(milliseconds: (1000 ~/60).toInt()), vsync: this);
        // curve =  CurvedAnimation(parent: controller, curve: Curves.elasticInOut)
        //   ..addListener(() {
        //     setState(() {
        //       curveValue = curve.value / 1000;
        //     });
        //   });
        animation = new Tween(begin: 150.0, end: 10.0).animate(controller)
          ..addListener(() {
           setState(() {
              print('anim=> ${animation.value}');
              curveValue =  animation.value;
            });
          });
    controller.addListener(() {
      updateCanvas(); 
      // loop();
      setState(() {});
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (DragStartDetails _d) {
          var pos = _d.globalPosition;
          this.mousePos = Offset(
              pos.dx, pos.dy - canvasOffsetY);
          _onTouch(this.mousePos);
          this.pushBubbleInArray();
        },
        child: LayoutBuilder(builder: (context, constraint) {
          canvasOffsetY = MediaQuery.of(context).size.height - constraint.maxHeight;
          this.canvasHeight = constraint.maxHeight;
          this.canvasWidth = MediaQuery.of(context).size.width;
          return Container(
            height: canvasHeight,
            width: canvasWidth,
            color: Colors.grey,
            child: CustomPaint(
              painter: BubbleChart(this.bubbleList),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
           controller.dispose();
        },
        tooltip: 'Increment',
        child: Icon(Icons.move_to_inbox),
      ),
    );
  }

  _onTouch(Offset mousePos) {

    double dx = mousePos.dx;
    double dy = mousePos.dy;
    print('dx=>${dx}, dy=>${dy}');
    this.bubbleList.forEach((_b) {
      var distanceToCenter =
        sqrt(pow(dx - _b.x, 2) + pow(dy - _b.y, 2));
    print('d=>$distanceToCenter');
      if (distanceToCenter < _b.r) {
        _b.color = Colors.lightBlue;
        _b.t = "Click!";
      }
    });
  }

  pushBubbleInArray() {
    if (this.bubbleList.length == 0) bubbleList.add(Ball(x: canvasWidth / 2, y: canvasHeight / 2, color: Colors.blue,t: "測試p", r: 60, vX: 2, vY: 0),);
    while(this.bubbleList.length < 10) {
      var _flag = true;
      var x = Random().nextInt(canvasWidth.toInt());
      var y = Random().nextInt(canvasHeight.toInt());
      var _distance = sqrt(pow(x - 0, 2) + pow( y - 0, 2));
      print('hasD => ${_distance.floor()}');
      this.bubbleList.forEach((_b) => ( getDistance(x - _b.x, y -_b.y) < _b.r * 2 )? _flag = false : _flag = _flag);
      if(_flag) this.bubbleList.add(Ball(x: x.toDouble(), y: y.toDouble(), color: Colors.blue,t: "測試p", r: 60, vX: 2, vY: 0),);
      print(_flag);
    }
    this.bubbleList.sort((a,b) => sortByDistToCenter(a,b));
  }

  void loop() {
     var _v = Vect();
     _v.x = 0;

    this.bubbleList.sort((a,b) => sortByDistToCenter(a,b));
    //  print('x===> ${_v.x}');
    for(var i = this.bubbleList.length - 1; i >= 0 ; --i) {
        var _i = this.bubbleList[i];
        var dX = _i.x - canvasWidth / 2;
        var dY = _i.y - canvasHeight / 2;
        // double distance = sqrt(pow(dX, 2) + pow(dY, 2));
        double distance = this.distToCenter(Offset(_i.x, _i.y));
        // if (distance >= _i.r * 2) {
          print('==11');
          var fps = 1;
          _i.vX = dX / fps;
          _i.vY = dY / fps;
          _i.x -= _i.vX ;
          _i.y -= _i.vY ;
          for(var j = i + 1; j < bubbleList.length; j++) {
            var _j = bubbleList[j];
            if(i == j) return;
            var dx = _j.x - _i.x;
            var dy = _j.y - _i.y;
            var r = _i.r + _j.r;
            var d = pow(dx, 2) + pow(dy, 2) ;
            if (d < (pow(r, 2) - 0.05) ) {
              _v.x = dx/ 1000;
              _v.y = dy /1000;
              _v.unit();
              _v.scale(r - (sqrt(d) / 2 ), r - (sqrt(d) / 2));
              print('vx =>${_v.x}, vy =>${_v.y}');
                _j.x -= _v.x;
                _j.y -= _v.y;
                _i.x += _v.x;
                _i.y += _v.y;
            }
          }
        // }
      }

      var damping = 0.1;//Number(iterationCounter);
      bubbleList.forEach((c){
          _v.x = c.x - centerPos.dx / 2;
          _v.y = c.y - centerPos.dy;
          _v.scale(damping, damping);
          c.x -= _v.x;
          c.y -= _v.y;
      });
  }
  //更新小球
  void updateCanvas() {
    this.bubbleList.sort((a,b) => sortByDistToCenter(a,b));
    this.bubbleList.forEach((_i) {
        var dX = _i.x - canvasWidth / 2;
        var dY = _i.y - canvasHeight / 2 - canvasOffsetY;
        // double distance = sqrt(pow(dX, 2) + pow(dY, 2));
        double distance = this.distToCenter(Offset(_i.x, _i.y));
        var d = pow(dX, 2) + pow(dY, 2);
        if ( d >= (pow(_i.r, 2) - 3600) ) {
          var fps = 200;
          _i.vX = dX / fps;
          _i.vY = dY / fps;
          _i.x -= _i.vX ;
          _i.y -= _i.vY ;
          this.bubbleList.forEach((_j) {
            var _dx = _i.x - _j.x;
            var _dy = _i.y - _j.y;
            if(_i == _j) return;
            var rr = pow((_i.r +_j.r),2);
            if(getDistance(_dx, _dy) <= _i.r *2 + 10) {
              print(getDistance(_i.x - _j.x, _i.y -_j.y));
              // if(getDistance(_j.x - canvasWidth / 2, _j.y - canvasHeight / 2) <= _j.r * 2)  return;
              var s = 1/150;
              var f = 1;
              _i.x += _dx * s * f;
              _i.y += _dy * s * f;
              print('重疊');
              _j.x -= _dx * s * f;
              _j.y -= _dy * s * f;
            }
          });
        }
        // if (dX.isNegative) {
        //   dX = dX.abs();
        //   _i.x += dX / 550;
        // } else if (dX != 0) {
        //   _i.x -= dX / 550;
        // }
        // if (dY.isNegative) {
        //   dY = dY.abs();
        //   _i.y += dY / 550;
        // } else if (dY != 0) {
        //   _i.y -= dY / 550;
        // }
        // _ball.vX += _ball.aX;
        // _ball.vY += _ball.aY;
        //限定下边界
        // if (_ball.y > _limit.bottom - _ball.r) {
        //   _ball.y = _limit.bottom - _ball.r;
        //   _ball.vY = -_ball.vY;
        //   // _ball.color=randomRGB();//碰撞后随机色
        // }
        // //限定上边界
        // if (_ball.y < _limit.top + _ball.r) {
        //   _ball.y = _limit.top + _ball.r;
        //   _ball.vY = -_ball.vY;
        //   // _ball.color=randomRGB();//碰撞后随机色
        // }
      // });
    });
    // bubbleList.forEach((_i){
    //     //   var _vx = c.x - centerPos.dx / 2;
    //     //   var _vy = c.y - centerPos.dy / 2;
    //     //   c.x -= _vx / 100;
    //     //   c.y -= _vy / 100;
    //     var dX = _i.x - canvasWidth / 2;
    //     var dY = _i.y - canvasHeight / 2 - canvasOffsetY;
    //     var d = pow(dX, 2) + pow(dY, 2);
    //       // print('<=');
    //       var fps = 1000;
    //       _i.vX = dX / fps;
    //       _i.vY = dY / fps;
    //       _i.x -= _i.vX ;
    //       _i.y -= _i.vY ;
    //   });
  }
  double dist(dX, dY) => sqrt(pow(dX, 2) + pow(dY, 2));
  double distToCenter(Offset pos) {
    var dX = pos.dx - centerPos.dx;
    var dY = pos.dy - centerPos.dy;
    var dist = sqrt(pow(dX, 2) + pow(dY, 2));
    return dist;
  }
  int sortByDistToCenter(a, b) {
    var valA = distToCenter(Offset(a.x, a.y));
    var valB = distToCenter(Offset(b.x, b.y));
    var comparVal = 0;
    if(valA > valB) comparVal = -1;
    else if(valA < valB) comparVal = 1;
    return 0 - comparVal;
  }
}

class BubbleChart extends CustomPainter {
  Paint bubblePaint;
  List<Ball> bubbleList;
  // Function delegateFunc;
  // Paragraph text = ParagraphStyle()
  BubbleChart(this.bubbleList);

  double r = 60.0;
  @override
  void paint(Canvas canvas, Size size) {
    // this.drawAll(canvas);
    this.bubbleList.forEach((obj) {
      // obj.x
      // print('(${obj.x}, ${obj.y})');
      this.drawBubble(canvas, obj.x, obj.y, obj.r, obj.t, obj.color);
    });
  }

  drawBubble(canvas, _dx, _dy, _r, _text, _color) {
    this.bubblePaint = new Paint()..color = _color;
    Path path = Path.combine(
        PathOperation.difference,
        Path()
          ..addOval(Rect.fromCircle(center: Offset(_dx, _dy), radius: _r + 1)),
        Path()..addOval(Rect.fromCircle(center: Offset(_dx, _dy), radius: _r)));
    canvas
      ..drawCircle(Offset(_dx, _dy), _r, bubblePaint)
      ..drawShadow(path, Colors.white, 2.0, true);
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: '微軟正黑體',
        textAlign: TextAlign.center,
        fontSize: 25.0,
        // textDirection: TextDirection.rtl,
        maxLines: 3,
      ),
    )
      ..addText(_text)
      ..pushStyle(ui.TextStyle(
        color: Colors.black,
      ));
    canvas.drawParagraph(
        paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: 60.0)),
        Offset(_dx - r / 2, _dy - r / 2));
  }

  // drawAll(canvas) {
  //   this.bubblePaint = new Paint()..color = Colors.purple;
  //   Path path = Path.combine(
  //       PathOperation.difference,
  //       Path()
  //         ..addOval(
  //             Rect.fromCircle(center: Offset(60, 60), radius: this.r + 1)),
  //       Path()
  //         ..addOval(Rect.fromCircle(center: Offset(60, 56), radius: this.r)));
  //   canvas
  //     ..scale(1.0)
  //     // ..drawOval(
  //     //     Rect.fromCircle(center: Offset(60, 60), radius: this.r), bubblePaint)
  //     ..drawCircle(Offset(60, 60), this.r, bubblePaint)
  //     // ..drawPath(path, bubblePaint)
  //     ..drawShadow(path, Colors.white, 2.0, true);

  //   // canvas.drawShadow(path, Colors.green, 4.0, true);
  //   // this.bubblePaint..color = Colors.black;
  //   canvas.drawParagraph(
  //       paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: 60.0)),
  //       Offset(30, 25));
  //   // canvas.drawCircle(Offset(50, 50), _ball.r, mPaint);
  // }

  @override
  bool shouldRepaint(BubbleChart oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(BubbleChart oldDelegate) => false;
}

class Vect {
  double x;
	double y;
  Vect({this.x, this.y});
  get len => sqrt(pow(x,2) + pow(y,2));
  scale(_x, _y) {
    x *= _x;
    y *= _y;
  }
  unit() {
    var s = 1/this.len;
	  this.scale(s, s);
  }
}

class Ball {
  double vX; // 速度X
  double vY; // 速度Y
  double x; // 点位X
  double y; // 点位Y
  String t; // 文字
  Color color; // 颜色
  double r; // 小球半径
  Ball({this.x, this.y, this.color, this.r, this.vX, this.vY, this.t});
  
}

class RunBallView extends CustomPainter {
  Paint mPaint;
  BuildContext context;
  Ball _ball;
  Rect _limit;

  RunBallView(this.context, Ball ball, Rect limit) {
    mPaint = new Paint();
    _ball = ball;
    _limit = limit;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var winSize = MediaQuery.of(context).size;
    canvas.translate(winSize.width / 2, winSize.height / 3);
    mPaint.color = Color.fromARGB(148, 198, 246, 248);
    var limit = Rect.fromLTRB(-winSize.width / 2, -winSize.height / 3,
        winSize.width / 2, winSize.height * 2 / 3);
    canvas.drawRect(limit, mPaint);
    canvas.save();
    // drawBall(canvas, _ball);
    drawBall(canvas, _ball);
    canvas.drawCircle(Offset(50, 50), _ball.r, mPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  //绘制小球
  void drawBall(Canvas canvas, Ball ball) {
    mPaint.color = ball.color;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, mPaint);
    // canvas.drawCircle(Offset(0, 0), ball.r, mPaint);
  }
}
