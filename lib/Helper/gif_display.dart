import 'package:flutter/material.dart';
import '../Game/GameEntity.dart';

class GifViewer extends StatefulWidget {

  final GameEntity gameEntity;

  GifViewer({@required this.gameEntity});

  @override
  _GifViewerState createState() => _GifViewerState();
}

class _GifViewerState extends State<GifViewer> with TickerProviderStateMixin{

  AnimationController _controller;
  Animation<int> _animation;

  final int nbFrames = 21;

  @override
  void initState() {
    _controller = new AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _animation = new IntTween(begin: 0, end: nbFrames).animate(_controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget child) {
          String frame = _animation.value.toString();
          return new Image.asset(
            'assets/images/coin_gif_tran/$frame.gif',
            width: widget.gameEntity.entityRadius *2,
            height: widget.gameEntity.entityRadius *2, // *2 special case of gold coin
            gaplessPlayback: true,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}