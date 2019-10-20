import 'package:flutter/material.dart';
import 'GameEntity.dart';
import 'package:flutter/animation.dart';

class PlanetWithGravityField extends StatefulWidget {
  final GameEntity entity;
  final double gravityField;

  PlanetWithGravityField({
    @required this.entity,
    @required this.gravityField
  });

  @override
  _PlanetWithGravityFieldState createState() => _PlanetWithGravityFieldState();
}

class _PlanetWithGravityFieldState extends State<PlanetWithGravityField>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 4),
    );

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
              child: Container(
                child: new AnimatedBuilder(
                  animation: controller,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent.withOpacity(0.5),
                    ),
                    height: widget.gravityField,
                    width: widget.gravityField,
                  ),
                  builder: (BuildContext context, Widget child) {
                    return new Transform.rotate(
                      angle: controller.value * 6.3,
                      child: child,
                    );
                  },
                ),
              )),
          widget.entity.image,
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class IndexDisplay extends StatelessWidget {

  final int index;
  final Widget child;

  IndexDisplay({this.index, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Positioned(
              child: Container(
                  child: child
              )),
          Positioned(child: Image.asset("assets/images/$index.png", width: 15.0, height: 15.0,)),
        ],
      ),
    );
  }
}


