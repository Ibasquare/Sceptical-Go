import 'package:flutter/material.dart';
import '../Helper/shared_preferences_helper.dart';
import 'menu.dart';
//------------------------------------------------------------------------------------------------
//                                  Shop in the level selection
//------------------------------------------------------------------------------------------------
class Carroussel extends StatefulWidget {
  final int spaceship;
  final int coins;
  final nbLevel;
  final galaxyCount;

  Carroussel(this.spaceship, this.coins, this.nbLevel, this.galaxyCount);

  @override
  _CarrousselState createState() => new _CarrousselState();
}

class _CarrousselState extends State<Carroussel> {
  PageController controller;
  int currentpage;
  int spaceshipSelected;
  int coins;

  @override
  initState() {
    super.initState();
    currentpage = widget.spaceship;
    coins = widget.coins;
    spaceshipSelected = widget.spaceship;
    controller = new PageController(
      initialPage: currentpage,
      keepPage: false,
      viewportFraction: 0.5,
    );
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        child: new PageView.builder(
            onPageChanged: (value) {
              setState(() {
                currentpage = value;
              });
            },
            controller: controller,
            itemCount: 6,
            itemBuilder: (context, index) => builder(index)),
      ),
    );
  }

  builder(int index) {
    return new AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        if (controller.position.haveDimensions) {
          value = controller.page - index;
          value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
        }

        return new Center(
          child: new SizedBox(
            height: Curves.easeOut.transform(value) * 300,
            width: Curves.easeOut.transform(value) * 250,
            child: child,
          ),
        );
      },
      child: new GestureDetector(
        onTap: () {
          setState(() {
            spaceshipSelected = index;
            currentpage = index;
          });
          if (coins > 1) {
            SharedPreferencesHelper.setCoins(-1);
            SharedPreferencesHelper.setSpaceship(index);
            alertBoxCaroussel(context, "Your ship has correctly been updated!",
                widget.nbLevel, widget.galaxyCount);
          }
          else 
          {
            alertBox(context, "You need more money to unlock a new spaceship");
          }
        },
        child: new Container(
          decoration: (isCurrent(index)
              ? BoxDecoration(
                  border: Border.all(
                  width: 10.0,
                  color: index % 2 == 0
                      ? const Color(0xFF1E88E5)
                      : const Color(0xFF5E35B1),
                ))
              : null),
          child: Image.asset(
              "assets/spaceships/space" + (index).toString() + ".png"),
          margin: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  isCurrent(int index) {
    return index == spaceshipSelected;
  }
}

final palette = [
  {'#E53935': 0xFFE53935},
  {'#D81B60': 0xFFD81B60},
  {'#8E24AA': 0xFF8E24AA},
  {'#5E35B1': 0xFF5E35B1},
  {'#3949AB': 0xFF3949AB},
  {'#1E88E5': 0xFF1E88E5},
  {'#039BE5': 0xFF039BE5},
  {'#00ACC1': 0xFF00ACC1},
  {'#00897B': 0xFF00897B},
  {'#43A047': 0xFF43A047},
  {'#7CB342': 0xFF7CB342},
  {'#C0CA33': 0xFFC0CA33},
];
//Recreated a specific alertBox that recreate the LevelSelection in order to update
// the number of coins.
void alertBoxCaroussel(
    BuildContext context, String message, var nbLevel, var galaxyCount) {
  var alert = new Dialog(
    child: Container(
      decoration: BoxDecoration(color: Colors.black),
      child: new Container(
        margin: const EdgeInsets.all(5.0),
        width: 300.0,
        height: 175.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Color(0xFFD1603D),
                Color(0xFF463E68),
              ],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
          borderRadius: new BorderRadius.circular(15.0),
          color: Color(0xFFD1603D),
        ),
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Text(
                message,
                style: TextStyle(fontFamily: 'AA', color: Colors.indigo[100]),
                textAlign: TextAlign.center,
              ),
              new FloatingActionButton(
                  onPressed: () {
                    //Remove alert box
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return new LevelSelection(nbLevel, galaxyCount);
                    }));
                  },
                  backgroundColor: Color(0xFFF06343),
                  child: Text("OK!", style: TextStyle(fontFamily: 'AA'))),
            ],
          ),
        ),
      ),
    ),
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}
