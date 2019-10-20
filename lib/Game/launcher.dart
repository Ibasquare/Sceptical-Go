import 'package:flutter/material.dart';
import 'GameEntity.dart';
import '../Helper/util.dart';

class Launcher extends StatefulWidget {
  SpaceShipGameEntity spaceship;
  Widget child;
  final start_simulation;

  Launcher(
      {@required this.spaceship, @required this.start_simulation, this.child});

  @override
  _LauncherState createState() => _LauncherState();
}

class _LauncherState extends State<Launcher>
    with SingleTickerProviderStateMixin {
  final Offset _min_speed = new Offset(50.0, 50.0);

  SpaceShipGameEntity _rocket;
  double _speed_calibration = 5.0;

  AnimationController _controller;

  bool _dragging = false;
  bool _launch = false;

  void _toggleDragState() {
    setState(() => _dragging = !_dragging);
  }

  @override
  didUpdateWidget(Launcher launcher) {
    super.didUpdateWidget(launcher);
    _dragging = false;
    _launch = false;
  }

  @override
  initState() {
    super.initState();
    _dragging = false;
    _launch = false;
    _rocket = widget.spaceship;
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        _toggleDragState();
      },
      onPanEnd: (details) {
        // Underscore is to know that you ignore all the arguments that are passed
        if (_dragging && !_launch) {
          _toggleDragState();
          Offset speed = details.velocity.pixelsPerSecond / _speed_calibration;
          if(speed.dx > _min_speed.dx || speed.dy > _min_speed.dy || speed.dx < -_min_speed.dx || speed.dy < -_min_speed.dy) {
            _launch = true;
            setState(() {
              _rocket.velocity = new VelocityClass(speed.dx, speed.dy);
              widget.start_simulation();
            });
          }
          else if(speed.dy.abs() < speed.dx.abs()){
            double ratio = (_min_speed.dy/speed.dy).abs();
            speed = Offset(speed.dx*ratio,speed.dy * ratio);
            _launch = true;
            setState(() {
              _rocket.velocity = new VelocityClass(speed.dx, speed.dy);
              widget.start_simulation();
            });
          }
          else if(speed.dy.abs() > speed.dx.abs()){
            double ratio = (_min_speed.dx/speed.dx).abs();
            speed = Offset(speed.dx * ratio,speed.dy*ratio);
            _launch = true;
            setState(() {
              _rocket.velocity = new VelocityClass(speed.dx, speed.dy);
              widget.start_simulation();
            });
          }
          else{
            speed = Offset(_min_speed.dx,_min_speed.dy);
            _launch = true;
            setState(() {
              _rocket.velocity = new VelocityClass(speed.dx, speed.dy);
              widget.start_simulation();
            });
          }
        }
      },
      child: widget.child,
    );
  }
}
