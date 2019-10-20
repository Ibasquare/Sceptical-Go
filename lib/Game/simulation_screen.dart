import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'PhysicalComponents.dart';
import 'puzzle.dart';
import 'GameEntity.dart';
import 'puzzle_screen.dart';
import 'collision_detection.dart';

class SimulationScreen extends StatefulWidget {
  final Puzzle puzzle;
  final handleEndGame;
  final BuildContext context;
  final Grid grid;

  SimulationScreen({@required this.puzzle, @required this.handleEndGame, @required this.context, @required this.grid});

  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  //Single is more efficient in the case of the class only ever needing one [Ticker]
  //TODO determine which one to use

  //Use [SingleTickerProviderStateMixin] classes to obtain a suitable [TickerProvider]

  //It will provide [Ticker] objects that are configured to only tick while the
  // current tree is enabled.

  //[Tickers] can be used by any object that wants to be notified whenever a frame
  //triggers: it will call it's callback once per animation frame.
  //Call 'start' and 'stop' to enable/disable the ticker.

  //The Ticker.start method returns a TickerFuture. The TickerFuture will
  // complete successfully if the Ticker is stopped using Ticker.stop with the
  // canceled argument set to false (the default)
  // Additional behaviour:
  // - If the Ticker is disposed without being stopped,
  // - or if it is stopped with canceled set to true,
  // then this Future will never complete.

  // --- Simulation part --- //
  Ticker ticker;

  var prec_elapsed = Duration();

  @override
  void initState() {
    super.initState();
    var entities = widget.puzzle.entities + widget.puzzle.actions;
    entities.add(widget.puzzle.spaceship);
    ticker = this.createTicker(_tick);
    ticker.start();
  }

  // Callback once per frame
  void _tick(Duration elapsed) {

    final double elapsedInSeconds =
    (elapsed - prec_elapsed).inMicroseconds.toDouble() / Duration.microsecondsPerSecond;

    prec_elapsed = elapsed;

    if (elapsedInSeconds > 0.0) {
      // ---- Apply action of each entity on spaceship ----- //

      //Gather every element in a list
      List<GameEntity> entities = widget.puzzle.entities + widget.puzzle.actions;

      entities.forEach((GameEntity entity) {
        // Remove element the spaceship has collided with (intended for coins)
        if(entity.crashed && entity.type != "asteroids"){
          widget.grid.removeEntity(entity);
          widget.puzzle.entities.remove(entity);
          widget.puzzle.removed.add(entity);
        }
        else {
          if(entity.type == "asteroids"){
            (entity.physics as AsteroidsPC).deltaT = elapsedInSeconds;
          }
          entity.update(widget.puzzle.spaceship, widget.grid);
        }
      });

      // ---- Update spaceship position ----- //
      widget.puzzle.spaceship.updatePosition(elapsedInSeconds, widget.grid);

      /* ----------------------- *\
          Checking game status
      \* ----------------------- */
      if (isSpaceshipCrashed() ) {
        ticker.stop();
        widget.handleEndGame(status: false, coins: widget.puzzle.spaceship.coins, restart:false); //Issue of the game
      }
      else if(hasLand()){
        ticker.stop();
        widget.handleEndGame(status: true, coins: widget.puzzle.spaceship.coins, restart:false); //Issue of the game
      }
      else{
        setState(() {

        });
      }
    }
  }

  bool isSpaceshipCrashed() {
    return widget.puzzle.spaceship.crashed;
  }

  bool hasLand(){
    return widget.puzzle.spaceship.hasLand;
  }

  bool isSpaceshipOut() {
    return !MediaQuery.of(context).size.contains(Offset(widget.puzzle.spaceship.position.x,
        widget.puzzle.spaceship.position.y));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black26,
        child: GestureDetector(
          onDoubleTap: () {
            ticker.stop();
            widget.handleEndGame(status: false, coins: 0, restart: true);
          },
          child: Container(
              color: Colors.transparent, // For gesture detector to fire
              child: Stack(children: (buildChildren(context)))
            // To display the HitBoxes
              //child: Stack(children: (buildChildren(context) + widget.grid.getHitBoxes())),
          ),
        )
    );
  }

  /// Build a list of Widget to be used as children of a [Stack]
  ///
  /// This is basically used to wrap the [GameEntities] into [Positioned] Widgets
  /// and potentially in [DraggableEntity] Widgets.
  List<Widget> buildChildren(BuildContext context) {
    List<Widget> list = List<Widget>();

    // Entities
    list.addAll(widget.puzzle.entities.map((item) => entityBuilder(item)));

    // Actions
    list.addAll(widget.puzzle.actions.map((item) => entityBuilder(item)));

    //End of puzzle
    list.add(widget.puzzle.end.positioned());

    list.add(widget.puzzle.spaceship.positioned());

    return list;
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }
}
