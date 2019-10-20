import 'package:flutter/material.dart';
import 'onboarding_background.dart';
import 'hint.dart';


class Page3 extends StatelessWidget {

  final bool videoHint;

  Page3({@required this.videoHint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.orange[400],
            Colors.red[600],
            Colors.red[900],
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
                      'Forgot what a planet is supposed to be?',
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
                          assetPath: "assets/tutos/tuto2.mp4",
                        )) : Image.asset("assets/tutos/tuto2.png"),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(
                      'Long press on elements to get information about it!',
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
