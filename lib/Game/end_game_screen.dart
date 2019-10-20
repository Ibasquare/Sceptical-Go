import 'package:flutter/material.dart';
import '../Onboarding/onboarding_background.dart';

class SelectionScreen extends StatelessWidget {
  final bool status;
  final int coins;

  SelectionScreen({this.status, this.coins});

  List<Widget> buildChildren(BuildContext context) {
    List<Widget> list = List<Widget>();

    list.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        (status ? "Congratulations! You won!" : "Oh no! You lost!"),
        textAlign: TextAlign.center,
        style: new TextStyle(
            color: Colors.black, fontSize: 30.0, fontFamily: 'AA'),
      ),
    ));

    list.add(Padding(
      padding: const EdgeInsets.all(20.0),
      child: RaisedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              (status ? "Next puzzle" : "Try again"),
              style: TextStyle(fontFamily: 'AA', fontSize: 20.0),
            ),
          )),
    ));

    if (coins != 0 && status)
      list.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/coin.png",
                  width: 100.0,
                  height: 100.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "You collected $coins coin"+(oneCoin()? "":"s"),
                    style: TextStyle(fontFamily: 'AA', fontSize: 18.0),
                  ),
                )
              ],
            ),
          )));
//
    return list;
  }

  bool oneCoin(){
    return coins == 1;
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope used to deactivate system backbutton
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.menu),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFFE53935),
              Color(0xFFD81B60),
              Color(0xFF5E35B1),
            ], begin: Alignment(0.5, -1.0), end: Alignment(0.5, 1.0))),
            child: Stack(alignment: FractionalOffset.center, children: <Widget>[
              Positioned(
                child: OnboardingBackGround(),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildChildren(context),
                ),
              ),
            ]),
          ),
        ));
  }
}
//LOST
// Try again

//WON:
// Next puzzle
