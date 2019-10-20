import 'package:flutter/material.dart';
import 'puzzle_screen.dart';
import 'puzzle.dart';
import 'simulation_screen.dart';
import '../Helper/layout_helper.dart';
import '../Helper/util.dart';
import 'dart:async' show Future;
import '../Menus/error_page.dart';
import 'end_game_screen.dart';
import '../Helper/shared_preferences_helper.dart';
import '../Onboarding/hint.dart';
import '../Game/GameEntity.dart';
import '../Menus/background.dart';
import 'collision_detection.dart';


const bool HINT_VIDEO = false;
// If set to false, the hint is an image,
// If set to true, the hint is a video.

/// The [GamePlay] Widget is the entry point into the game, strictly speaking.
/// Once the user has selected a puzzle, an instance of [GamePlay] is created.
///
/// There are two phases to this Widget:
///
/// * User actions: this is the phase where the user can put actions on the screen
///   in order to solve the puzzle
///
/// * Simulation: this is the phase where the spaceship is animated and the issue
///   of the puzzle (win or loose) is determined.

class GamePlay extends StatefulWidget {
  final String filepath;
  final int galaxyNb; //The galaxy the puzzle is in
  final int puzzleNb; //The puzzle number
  final int nbLevel; //The number of puzzle in that galaxy

  GamePlay(
      {@required this.filepath,
      @required this.galaxyNb,
      @required this.puzzleNb,
      @required this.nbLevel});

  @override
  _GamePlayState createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  bool _simulationStart = false; //Will be modified by children widget

  Map<String, Coordinates> initialPositionsBluePrints;
  bool doLayout = true;

  // Loading puzzle
  Grid grid;
  Puzzle puzzle;
  Future<Puzzle> future;

  // Loading help
  Future<Function> futureFunction;
  Future<int> futureSpaceship;

  @override
  void initState() {
    super.initState();
    futureFunction = displayHelp();
    futureSpaceship = SharedPreferencesHelper.getSpaceship();

    future = new Future.delayed(Duration.zero, () {
      puzzle = Puzzle();
      return puzzle.loadPuzzle(context, widget.filepath);
    });
  }

  ///Callback from puzzleScreen
  void _handleSimulationStart() {
    setState(() {
      _simulationStart = !_simulationStart;
    });
  }

  ///Callback from simulationScreen
  ///
  ///status: false = game lost, true = game won
  ///coins: the number of coins collected by player
  ///restart: whether to display choice or restart game right away
  void _navigateAndDisplayChoice({bool status, int coins, bool restart}) async {

    // ---- Player wants to restart without waiting end of game --- //
    if (restart){
      // Reset spaceship position and velocity
      resetGame();
      setState(() {
        _simulationStart = !_simulationStart;
      });
      return;
    }

    // ---- Display end of game Screen ---- //
    final bool choice = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionScreen(status: status, coins: coins,)),
    );

    // ------ Player Won ----- //
    if (status) {
      // ---- Update nb puzzles unlocked ---- //
      var lastPuzzleUnlocked = await SharedPreferencesHelper.getPuzzlesUnlocked(
          galaxy: widget.galaxyNb);
      if (lastPuzzleUnlocked == widget.puzzleNb)
        await SharedPreferencesHelper.setPuzzlesUnlocked(widget.puzzleNb + 1,
            galaxy: widget.galaxyNb);

      if (widget.puzzleNb == widget.nbLevel - 1) {
        //Player unlocked last level -> Access to new galaxy
        await SharedPreferencesHelper.setGalaxiesUnlocked(widget.galaxyNb + 1);
      }
      if (coins != 0) await SharedPreferencesHelper.setCoins(coins);

      // --- Handle player choice ---- //
      if (choice) {
        //If user gain all the levels of the galaxy
        if (widget.puzzleNb+1 == widget.nbLevel)
            Navigator.of(context).pop();
        //Launch next puzzle
        else
        {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              Background(
                delay: 5,
                nbStars: 1000,
              ),
              GamePlay(
                filepath: 'assets/puzzles/Galaxy${widget.galaxyNb}/puzzle${widget.puzzleNb + 1}.json',
                galaxyNb: widget.galaxyNb,
                puzzleNb: widget.puzzleNb + 1,
                nbLevel: widget.nbLevel,
              ),
            ],
          );
        }));
        }
      } else {
        //Return to main menu
        Navigator.pop(context);
      }
    }

    // ------ Player lost ------- //
    else {
      if (choice) {
        //Try again
        // Reset
        resetGame();
        setState(() {
          _simulationStart = !_simulationStart;
        });
      } else {
        //Return to main menu
        Navigator.pop(context);
      }
    }
  }

  /// Used when double tap during simulation or when the user lost
  void resetGame() {

    // ---- Reset spaceship
    puzzle.spaceship.position = puzzle.start.copy();
    puzzle.spaceship.velocity =
        VelocityClass(0.0, 0.0);
    puzzle.spaceship.forceApplied = [0.0, 0.0];
    puzzle.spaceship.crashed = false;
    puzzle.spaceship.coins = 0;
    puzzle.spaceship.hasCollided = false;

    // ---- Reset removed entities
    puzzle.entities.addAll(puzzle.removed);
    puzzle.removed.clear();

    // ---- Reset all entities
    List<GameEntity> entities = puzzle.entities + puzzle.actions;

    entities.forEach((GameEntity entity) {
      entity.reset();
    });

    // ---- Reset the grid ---- //
    grid.resetGrid();
    grid.setEntity(puzzle.entities);
  }


  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.landscape) {
        return Center(
          child: Image.asset(
            'images/rotate_phone.png',
            width: 100.0,
            height: 100.0,
          ),
        );
      } else {
        // ------------------------- \\
        //    Simulation phase
        // ------------------------- \\
        if (_simulationStart) {
          return SimulationScreen(
            puzzle: puzzle,
            handleEndGame: _navigateAndDisplayChoice,
            context: context,
            grid: grid,
          );
        }
        // ------------------------- \\
        //      Puzzle phase
        // ------------------------- \\
        else {
          return FutureBuilder(
            future: Future.wait([futureFunction, futureSpaceship, future]).then(
                    (response) => MergedFutures(first: response[0], second: response[1], third: response[2])),

              builder: (BuildContext context, AsyncSnapshot<MergedFutures> snapshot) {
                if (snapshot.hasError)
                  return errorPage(context, snapshot.error.toString());

                if (snapshot.hasData) {
                  // Layout puzzle according to screen size
                  if (doLayout) {
                    initialPositionsBluePrints = layoutPuzzle(context, puzzle, snapshot.data.second);
                    doLayout = false;
                    grid = Grid(entities: puzzle.entities, context: context);
                  }
                  return PuzzleScreen(
                    puzzle: puzzle,
                    onSimulationStart: _handleSimulationStart,
                    initialPositionsBluePrints: initialPositionsBluePrints,
                    displayHelp: snapshot.data.first,
                    grid: grid,
                  );
                } else
                  return new CircularProgressIndicator();
              });
        }
      }
    });
  }

  /// This function determines if help needs to be displayed for the current puzzle
  /// - First we look if the puzzle has some hint assigned to it
  /// - Then we look to see if the player has already seen that hint
  Future<Function> displayHelp() async {

    // Check: see if this puzzle requires help
    String tuto =
        Puzzle.info[widget.galaxyNb.toString() + widget.puzzleNb.toString()];
    if (tuto == null) // No help should be displayed
    {
      //print("Help is planned for this puzzle: $tuto");
      return () {};
    }

    // Check: see if the user has already seen the help
    var needToDisplayHelp = await SharedPreferencesHelper.hint(tuto);
    if (needToDisplayHelp) {
      return () =>
          displayHint(GameEntity.info[tuto], "assets/tutos/$tuto", context, HINT_VIDEO);
    } else {
      return () {};
    }
  }
}

