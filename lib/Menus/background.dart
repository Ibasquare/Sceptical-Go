import 'dart:math';
import 'package:flutter/material.dart';

class Background extends StatefulWidget {
  int _delay;
  int _nbStars;

  Background({@required int delay, @required int nbStars}){
    this._delay = delay;
    this._nbStars = nbStars;
  }
  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new BackgroundFont(),
        new Space(
          delay: widget._delay,
          nbStars: widget._nbStars,
        ),
      ],
    );
  }
}

class BackgroundFont extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new DecoratedBox(
        decoration: new BoxDecoration(
          gradient: new RadialGradient(
            stops: [
              0.001,
              0.09,
              0.199,
              0.2,
              0.6,
            ],
            radius: 2.0,
            colors: [
              // Colors are easy thanks to Flutter's
              // Colors class.
              Colors.blue[800],
              Colors.blue[900],
              Colors.indigo[900],
              Colors.indigo[900],
              Colors.black,
            ],
          ),
        ),
      ),
    );
  }
}

class Space extends StatefulWidget {
  int _delay;
  int _nbStars;

  Space({@required int delay,@required  int nbStars}){
    this._delay = delay;
    this._nbStars = nbStars;
  }

  @override
  _SpaceState createState() => _SpaceState();
}

class _SpaceState extends State<Space> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<Star> _stars;
  int _tick;
  int _delay;
  int _nbStars;
  Random random_number_generator =
  Random(DateTime.now().millisecondsSinceEpoch);

  @override
  void initState() {
    super.initState();
    _stars = new List<Star>();
    _delay = widget._delay;
    _nbStars = widget._nbStars;
    _tick = _delay;
    _controller = new AnimationController.unbounded(
      value: 0.0,
      duration: Duration(hours: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void killStars() {
    for (int i = 0; i < _stars.length; i++) {
      if (!(_stars[i].isAlive())) {
        _stars.removeAt(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
        animation: _controller,
        child: new Stack(fit: StackFit.expand, children: _stars),
        builder: (BuildContext context, Widget child) {
          if (_stars.length < _nbStars && _tick <= 0) {
            final mediaQueryData =
            MediaQuery.of(context); // Get the Dimensions of the screen
            _stars.add(
              Star(
                xPos: (random_number_generator.nextDouble()) *
                    mediaQueryData.size.width,
                yPos: random_number_generator.nextDouble() *
                    mediaQueryData.size.height,
                radius: 2.0,
                birthTime: DateTime.now(),
                life_time: 20 + random_number_generator.nextInt(10),
                moving: (random_number_generator.nextDouble() > 9 / 10
                    ? true
                    : false),
              ),
            );
            _tick = _delay;
            return new Stack(fit: StackFit.expand, children: _stars);
          } else {
            killStars();
            _tick--;
            return child;
          }
        });
  }
}

class Star extends StatefulWidget {
  double _xPos;
  double _yPos;
  double _radius;
  DateTime _birthTime;
  int _life_time;
  bool _moving;
  Color _color;
  bool _permanent;

  Star(
      {@required double xPos,
        @required double yPos,
        @required double radius,
        @required DateTime birthTime,
        @required int life_time,
        @required bool moving, Color color, bool permanent}) {
    this._xPos = xPos;
    this._yPos = yPos;
    this._radius = radius;
    this._birthTime = birthTime;
    this._life_time = life_time;
    this._moving = moving;
    if(permanent != null){
      this._permanent = permanent;
    }
    else{
      this._permanent = false;
    }
    if(color != null){
      this._color = color;
    }
    else{
      this._color = Colors.white;
    }
  }

  bool isAlive() {
    if(this._permanent){
      return true;
    }
    else {
      DateTime now = DateTime.now();
      return (now
          .difference(_birthTime)
          .inSeconds > _life_time) ? false : true;
    }
  }

  @override
  _StarState createState() => _StarState();
}

class _StarState extends State<Star> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Offset _position;
  double _radius;
  bool _moving;
  bool _permanent;
  Color _color;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    _position = Offset(widget._xPos, widget._yPos);
    _radius = widget._radius;
    _moving = widget._moving;
    _permanent = widget._permanent;
    _color = widget._color;
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: widget._life_time),
    )..repeat();
  }

  bool contains(Offset offset) {
    double dist = sqrt(pow((_position.dx - offset.dx), 2) -
        pow((_position.dy - offset.dy), 2));
    return dist > _radius ? false : true;
  }

  Widget build(BuildContext context) {
    return new AnimatedBuilder(
        animation: _controller,
        child: new CustomPaint(
          size: Size.infinite,
          painter: CanvasStar(
            position: _position,
            radius: _radius,
            fill: _color,
          ),
        ),
        builder: (BuildContext context, Widget child) {
          Widget new_widget;
          if (!_moving) {
            new_widget = child;
          } else {
            _position += Offset(5.0, -5.0);
            new_widget = new CustomPaint(
              size: Size.infinite,
              painter: CanvasStar(
                position: _position,
                radius: _radius,
                fill: Colors.white,
              ),
            );
          }
          if(_permanent){
            return new_widget;
          }
          else{
            return new Opacity(
                opacity: 1.0 - _controller.value, child: new_widget);
          }
        });
  }
}

class CanvasStar extends CustomPainter {
  Offset _position;
  double _radius;
  Paint fill;

  CanvasStar({@required Offset position,@required double radius,@required Color fill}){
    this._position = position;
    this._radius = radius;
    this.fill = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(_position, _radius, fill);
  }

  @override
  bool shouldRepaint(CanvasStar oldDelegate) {
    return oldDelegate._position != _position ||
        oldDelegate._radius != _radius ||
        oldDelegate.fill != fill;
  }
}

