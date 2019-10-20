import 'package:flutter/material.dart';
import 'Menus/menu.dart';
import 'Onboarding/onboarding.dart';
import 'Onboarding/onboarding_background.dart';
import 'dart:async' show Future;
import 'Helper/shared_preferences_helper.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Sceptical Go!',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run
        //
        // ". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: new HomePage(title: 'Sceptical Go!'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<bool> firstTime;
  bool first;

  //-------- Carousel ------ //

//  void _pushTest()
//  {
//    Navigator.of(context).push(new MaterialPageRoute(
//        builder: (BuildContext context) {
//          return VideoPlayerCustom(assetPath: "assets/tutos/tuto1.mp4");}));
//  }
//  ------- SpaceBackground ------- //


  void _pushTest() {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return OnBoardingScreens();
    }));
  }



  void _pushMenu() {
    if (first) // First time for user -> Display Onboarding
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (BuildContext context) {
        return OnBoardingScreens();
      }));
    else
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (BuildContext context) {
        return MainMenu();
      }));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    firstTime = SharedPreferencesHelper.onboardingMain();

    return new Scaffold(
        //backgroundColor: Colors.blueGrey,
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFFD1603D),
        Color(0xFFF06343),
        Color(0xFF463E68),
      ], begin: Alignment(0.5, -1.0), end: Alignment(0.5, 1.0))),
      child: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Stack(
          children: <Widget>[
            OnboardingBackGround(),
            Center(
                child: FutureBuilder(
                    future: firstTime,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) return Text("Oh no"); //TODO

                      if (snapshot.hasData) {
                        first = snapshot.data;
                        String buttonText;
                        if (snapshot.data) // First Time
                          buttonText = "Start Demo";
                        else
                          buttonText = "Start Game";

                        return Column(
                          // Column is also layout widget. It takes a list of children and
                          // arranges them vertically. By default, it sizes itself to fit its
                          // children horizontally, and tries to be as tall as its parent.
                          //
                          // Invoke "debug paint" (press "p" in the console where you ran
                          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
                          // window in IntelliJ) to see the wireframe for each widget.
                          //
                          // Column has various properties to control how it sizes itself and
                          // how it positions its children. Here we use mainAxisAlignment to
                          // center the children vertically; the main axis here is the vertical
                          // axis because Columns are vertical (the cross axis would be
                          // horizontal).
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Sceptical Go",
                              style: TextStyle(
                                  fontSize: 34.0,
                                  color: Colors.white,
                                  fontFamily: 'AA'),
                            ),
                            MovingPlanet(),
                            ButtonTheme(
                              minWidth: 250.0,
                              child: new RaisedButton(
                                onPressed: _pushMenu,
                                child: new Text(
                                  buttonText,
                                  style: new TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.white,
                                      fontFamily: 'AA'),
                                ),
                                color: Colors.black26,
                                elevation: 1.0,
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0)),
                              ),
                            ),
//                            ButtonTheme(
//                              minWidth: 150.0,
//                              child: new RaisedButton(
//                                onPressed: _pushTest,
//                                child: new Text(
//                                  'About Us',
//                                  style: new TextStyle(
//                                      fontSize: 24.0,
//                                      color: Colors.white,
//                                      fontFamily: 'AA'),
//                                ),
//                                color: Colors.black26,
//                                elevation: 1.0,
//                                shape: new RoundedRectangleBorder(
//                                    borderRadius:
//                                        new BorderRadius.circular(15.0)),
//                              ),
//                            ),
                          ],
                        );
                      } else
                        return new CircularProgressIndicator();
                    })),
          ],
        ),
      ),
    ));
  }
}

// ---------------------------------------------------------------------------

class MovingPlanet extends StatefulWidget {
  @override
  State createState() => new MovingPlanetState();
}

class MovingPlanetState extends State<MovingPlanet>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        lowerBound: -1.0,
        upperBound: 1.0,
        duration: new Duration(milliseconds: 1000),
        vsync: this);
    animation = Tween(begin: -1.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward(from: -1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue,
      width: 200.0,
      height: 200.0,
      alignment: Alignment(0.0, 0.2 * animation.value),
      child:
          Image.asset('assets/images/saturn.png', width: 150.0, height: 150.0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
