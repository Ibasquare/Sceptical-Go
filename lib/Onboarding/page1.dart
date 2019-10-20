import 'package:flutter/material.dart';
import 'onboarding_background.dart';
import 'hint.dart';


class Page1 extends StatelessWidget {

  final bool videoHint;

  Page1({@required this.videoHint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.green[400],
        Colors.blue[600],
        Colors.blue[900],
      ], begin: Alignment(0.5, -1.0), end: Alignment(0.5, 1.0))),
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: FractionalOffset.center,
        children: <Widget>[
          new Positioned(
            child: OnboardingBackGround(),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned.fill(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Find your way in space!',
                  style: TextStyle(
                      fontSize: 20.0, color: Colors.white, fontFamily: 'AA'),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 300.0,
                height: 300.0,
                child: videoHint? AspectRatio(
                    aspectRatio: 9 / 16,
                    child: VideoPlayerCustom(
                      assetPath: "assets/tutos/tuto0.mp4",
                    )) : Image.asset("assets/tutos/tuto0.png"),
              ),
              new Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Use gravity to take the right turn at the right time!',
                  style: TextStyle(
                      fontSize: 12.0, color: Colors.white, fontFamily: 'AA'),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
