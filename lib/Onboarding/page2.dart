import 'package:flutter/material.dart';
import 'onboarding_background.dart';
import 'hint.dart';


class Page2 extends StatelessWidget {

  final bool videoHint;

  Page2({@required this.videoHint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.pink[400],
            Colors.deepPurple[600],
            Colors.deepPurple[900],
          ],
              begin: Alignment(0.5, -1.0),
              end: Alignment(0.5, 1.0))
      ),
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
                      'Double tap to reset the game and start anew',
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
                          assetPath: "assets/tutos/tuto1.mp4",
                        )) : Image.asset("assets/tutos/tuto1.png"),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(
                      'At any time, you can always reset the game to its original state',
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
