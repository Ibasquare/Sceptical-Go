import 'package:flutter/material.dart';
import 'dart:async' show Future, StreamController, Stream;
import 'dart:convert';
import '../Menus/error_page.dart';
import '../Menus/background.dart';
import '../Game/gameplay.dart';
import '../Helper/shared_preferences_helper.dart';
import '../Menus/store_carousel.dart';
import '../Helper/util.dart';

class MainMenu extends StatefulWidget {
  @override
  MainMenuState createState() => new MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  Future<List<Object>> future;
  var nbGalaxyTotal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    future = _loadFiles(context);
  }

  Future<List<Object>> _loadFiles(BuildContext context) async {
    // --- Load file describing galaxies --- //
    final json = DefaultAssetBundle.of(context)
        .loadString("assets/puzzles/description_levels.json");
    final Map<String, dynamic> data = JsonDecoder().convert(await json);

    var map = Map<String, int>();
    if (data['nb_puzzles_by_galaxy'] == null) throw "Error reading file";

    var nbPuzzleUnlockByGalaxy = [];
    var nbPuzzlesByGalaxy = (data['nb_puzzles_by_galaxy'] as List);

    for (int i = 0; i < nbPuzzlesByGalaxy.length; i++) {
      map['Galaxy$i'] = nbPuzzlesByGalaxy[i];
      nbPuzzleUnlockByGalaxy
          .add(await SharedPreferencesHelper.getPuzzlesUnlocked(galaxy: i));
    }

    // --- Load nb galaxies unlocked --- //
    var nbGalaxy = await SharedPreferencesHelper.getGalaxiesUnlocked();
    this.nbGalaxyTotal = nbPuzzlesByGalaxy.length;

    return [map, nbGalaxy, nbPuzzleUnlockByGalaxy];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) return errorPage(context, snapshot.error);

          if (snapshot.hasData)
            return createGalaxyList(snapshot.data);
          else
            return new CircularProgressIndicator();
        });
  }

  Widget createGalaxyList(List<Object> info) {
    Map<String, int> data = info[0];
    int lastUnlocked = info[1];
    var nbPuzzleUnlockByGalaxy = info[2];
    return GalaxyMenu(data, lastUnlocked, nbPuzzleUnlockByGalaxy, nbGalaxyTotal);
  }
}
//------------------------------------------------------------------------------------------------
//                                  Menu with the galaxies
//------------------------------------------------------------------------------------------------

class GalaxyMenu extends StatefulWidget {
  final listGalaxy;
  final lastGalaxyUnlock;
  final nbPuzzleUnlockByGalaxy;
  final nbGalaxy;
  GalaxyMenu(
      this.listGalaxy, this.lastGalaxyUnlock, this.nbPuzzleUnlockByGalaxy, this.nbGalaxy);
  State<StatefulWidget> createState() => GalaxyMenuState();
}

class GalaxyMenuState extends State<GalaxyMenu> {
  var top = 1.0; //Initial position on the background image
  var _height = 1600; // height of the background image
  var nbGalaxy ;
  var unlock = new List();
  var nbLevel = new List();
  var nbUnlock = new List();
  //List of controller use to link the button the the movement of the background image
  var listController = new List();  
  var posGalaxy = new List();
  Future<int> futureCoins;

  @override
  void initState() {
    super.initState();
    nbGalaxy = widget.nbGalaxy;
    posGalaxy = GALAXYPOS;

    futureCoins = SharedPreferencesHelper.getCoins();
    for (var i = 0; i < nbGalaxy; i++) {
      nbLevel.add(widget.listGalaxy['Galaxy$i']);
      listController.add(new StreamController<double>());
      listController[i].add(top);
    }
  }

  @override
  Widget build(BuildContext context) {
    //Regets the number of coins each time (if pop())
    futureCoins = SharedPreferencesHelper.getCoins();
    return FutureBuilder(
        future: futureCoins,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) return errorPage(context, snapshot.error);
          if (snapshot.hasData)
            return buildGalaxy(snapshot.data);
          else
            return buildGalaxy(0);
        });
  }

  Widget buildGalaxy(int coins) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Select Galaxy!',
          style: TextStyle(
            fontFamily: 'AA',
          ),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(coins.toString(),
                        style: TextStyle(fontFamily: 'AA')),
                  ),
                  Image.asset('assets/images/coin.png',
                      width: 15.0, height: 15.0),
                ],
              ))
        ],
      ),
      body: new GestureDetector(
        onVerticalDragUpdate: (v) {
          setState(() {
            //Computaiton of the relative movement of the button compare to the 
            // movement of the background image
            top -= v.delta.dy / (_height / 4);
            if (top > 1.0)
              top = 1.0;
            else if (top < -1.0) top = -1.0;
            for(int i =0; i<nbGalaxy;i++)
              this.listController[i].add(top);
          });
        },
        //background image
        child: new Container(
            constraints: new BoxConstraints.expand(
              height: double.infinity,
            ),
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    alignment: new Alignment(0.0, top),
                    image: new AssetImage(
                      'assets/images/fond.png',
                    ),
                    fit: BoxFit.none)),
            child: new Stack(
              children: createChildrenGalaxy(),
            )),
      ),
    );
  }
  //Create the number of galaxy present in the json
  List<Widget> createChildrenGalaxy() {
    return new List<Widget>.generate(this.nbGalaxy, (int index) {
      return Galaxy(
        listController[index].stream,
        posGalaxy[index][0],
        posGalaxy[index][1],
        index + 1,
        index <= widget.lastGalaxyUnlock ? true : false,
        nbLevel[index],
        widget.nbPuzzleUnlockByGalaxy[index]
      );
    });
  }
}

//------------------------------------------------------------------------------------------------
//                                  Class for the galaxy button itself
//------------------------------------------------------------------------------------------------
class Galaxy extends StatefulWidget {
  final Stream<double> stream;
  final dx;
  final dy;
  final galaxyCount;
  final unlock;
  final nbLevel;
  final nbUnlock;
  Galaxy(this.stream, this.dx, this.dy, this.galaxyCount, this.unlock,
      this.nbLevel, this.nbUnlock);
  State<StatefulWidget> createState() => GalaxyState();
}

class GalaxyState extends State<Galaxy> {
  var top;
  var dx;
  var dy;
  var galaxyCount;
  var nbLevel;

  @override
  initState() {
    super.initState();
    //Should be useless but to be sure
    top = 0.0;
    dx = widget.dx;
    dy = widget.dy;
    galaxyCount = widget.galaxyCount;
    nbLevel = widget.nbLevel;
    widget.stream.listen((topy) => setState(() => top = topy));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: new Alignment(dx, -(top + dy)),
      child: new FlatButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          // Check if the galaxy is unlock
          widget.unlock
              ? Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                  return new LevelSelection(widget.nbLevel, widget.galaxyCount);
                }))
              : alertBox(context, "You need to unlock this galaxy to go there");
        },
        child: new ConstrainedBox(
          constraints: BoxConstraints.expand(
            width: 100.0,
            height: 130.0,
          ),
          child: new Column(
            children: <Widget>[
              new Image.asset(
                "assets/images/galaxy" + galaxyCount.toString() + ".png",
                fit: BoxFit.fill,
                // Color the galaxy in grey if not unlock
                color: widget.unlock ? null : Colors.grey,
              ),
              new Column(
                children: <Widget>[
                  new Text("Galaxy " + this.galaxyCount.toString(),
                      style: TextStyle(
                          fontFamily: 'AA', color: Colors.yellowAccent[700])),
                  new Text(
                      widget.nbUnlock.toString() + " / " + nbLevel.toString(),
                      style:
                          TextStyle(fontFamily: 'AA', color: Colors.lime[200]))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
//------------------------------------------------------------------------------------------------
//                                  Alert box method. 
// Used to be class specific but it was reuse in other part of the project
//------------------------------------------------------------------------------------------------
void alertBox(BuildContext context, String message) {
  //Need to create a need type of Dialog since the one existing didn't fit what we wanted
  var alert = new Dialog(
    child: Container(
      decoration: BoxDecoration(color: Colors.black),
      child: new Container(
        margin: const EdgeInsets.all(5.0),
        width: 300.0,
        height: 175.0,
        decoration: BoxDecoration(
          //background color
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
//------------------------------------------------------------------------------------------------
//                                  Menu for the levels
//------------------------------------------------------------------------------------------------
class LevelSelection extends StatefulWidget {
  final nbLvl;
  final galaxyCount;
  LevelSelection(this.nbLvl, this.galaxyCount);

  @override
  LevelSelectionState createState() {
    return new LevelSelectionState();
  }
}

class LevelSelectionState extends State<LevelSelection>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  Future<int> futureCoins;
  Future<int> futureSpaceship;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  TabBar makeTabBar() {
    return TabBar(tabs: <Tab>[
      Tab(
        icon: Icon(Icons.apps),
      ),
      Tab(
        icon: Icon(Icons.airplanemode_active),
      ),
    ], controller: tabController);
  }

  TabBarView makeTabBarView(tabs) {
    return TabBarView(
      children: tabs,
      controller: tabController,
    );
  }

  Widget buildTabBar(int coins, int spaceship, int nbLevel) {
    return new Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Levels',
          style: TextStyle(
            fontFamily: 'AA',
          ),
        ),
        bottom: makeTabBar(),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(coins.toString(),
                        style: TextStyle(fontFamily: 'AA')),
                  ),
                  Image.asset('assets/images/coin.png',
                      width: 15.0, height: 15.0),
                ],
              ))
        ],
      ),
      // Creating a TabBar object with the levels and the shop
      body: makeTabBarView(<Widget>[
        SelectionMenu(nbLevel, widget.galaxyCount),
        Container(
          child: Stack(children: <Widget>[
            Background(
              delay: 5,
              nbStars: 1000,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Choose your spaceship!",
                  style: TextStyle(fontFamily: 'AA', color: Colors.white),
                ),
                Container(
                  height: 300.0,
                  child: Carroussel(spaceship,coins, widget.nbLvl, widget.galaxyCount),
                )
              ],
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Regain of these two variable for each build (if pop())
    futureCoins = SharedPreferencesHelper.getCoins();
    futureSpaceship = SharedPreferencesHelper.getSpaceship();
    return FutureBuilder(
        future: Future.wait([futureCoins, futureSpaceship]).then((response) =>
            MergedFutures(first: response[0], second: response[1])),
        builder: (BuildContext context, AsyncSnapshot<MergedFutures> snapshot) {
          if (snapshot.hasError) return errorPage(context, snapshot.error);
          if (snapshot.hasData)
            return buildTabBar(
                snapshot.data.first, snapshot.data.second, widget.nbLvl);
          else
            return CircularProgressIndicator();
        });
  }
}
//------------------------------------------------------------------------------------------------
//                                  Body of the level selection 
//  This class is in charge for the level list. Not for the shop which is in store_carousel
//------------------------------------------------------------------------------------------------
class SelectionMenu extends StatefulWidget {
  final nbLevel;
  final galaxyCount;
  SelectionMenu(this.nbLevel, this.galaxyCount);

  @override
  SelectionMenuState createState() => SelectionMenuState();
}

class SelectionMenuState extends State<SelectionMenu> {
  Future<int> nbLvlUnlock;
  @override
  void initState() {
    super.initState();
    nbLvlUnlock = SharedPreferencesHelper.getPuzzlesUnlocked(
        galaxy: widget.galaxyCount - 1);
  }

  @override
  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    nbLvlUnlock = SharedPreferencesHelper.getPuzzlesUnlocked(
        galaxy: widget.galaxyCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    nbLvlUnlock = SharedPreferencesHelper.getPuzzlesUnlocked(
        galaxy: widget.galaxyCount - 1);
    return FutureBuilder(
        future: nbLvlUnlock,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) return errorPage(context, snapshot.error);
          if (snapshot.hasData)
            return buildList(snapshot.data);
          else
            return buildList(0);
        });
  }

  Widget buildList(int nbLevelUnlock) {
    return Container(
        color: Colors.grey[350],
        child: ListView.separated(
          padding: EdgeInsets.all(15.0),
          itemCount: widget.nbLevel,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (context, i) {
            // Determine if galaxy unlocked or not
            return buildListTile(context, i, i <= nbLevelUnlock);
          },
        ));
  }

  ListTile buildListTile(BuildContext context, int i, bool unlocked) {
    if (unlocked)
      return ListTile(
        leading: Image.asset(
          'assets/images/Planet${i%18}.png',
          width: 90.0,
          height: 90.0,
        ),
        title: Text(
          'Level ${i + 1}',
          style: TextStyle(fontFamily: 'AA'),
        ),
        onTap: () {
          var galaxyCount = widget.galaxyCount - 1;
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return Stack(
              children: <Widget>[
                Background(
                  delay: 5,
                  nbStars: 1000,
                ),
                GamePlay(
                  filepath: 'assets/puzzles/Galaxy$galaxyCount/puzzle$i.json',
                  galaxyNb: galaxyCount,
                  puzzleNb: i,
                  nbLevel: widget.nbLevel,
                ),
              ],
            );
          }));
        },
      );
    else
      return ListTile(
        leading: Image.asset(
          'assets/images/Planet${i%18}.png',
          width: 90.0,
          height: 90.0,
          color: Colors.grey,
        ),
        title: Text(
          'Level ${i + 1}',
          style: TextStyle(fontFamily: 'AA'),
        ),
      );
  }
}
