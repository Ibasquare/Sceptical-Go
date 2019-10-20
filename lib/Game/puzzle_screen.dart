import 'package:flutter/material.dart';
import 'puzzle.dart';
import 'GameEntity.dart';
import 'draggable_widget.dart';
import '../Helper/util.dart';
import 'gravity_field_display.dart';
import '../Onboarding/hint.dart';
import 'launcher.dart';
import '../Helper/gif_display.dart';
import 'collision_detection.dart';
import '../Menus/menu.dart';

const bool HINT_VIDEO = false;
// If set to false, the hint is an image,
// If set to true, the hint is a video.

class PuzzleScreen extends StatefulWidget {
  final onSimulationStart;
  final Puzzle puzzle;
  final Grid grid;
  // initial Positions for each type of bluePrint
  final Map<String, Coordinates> initialPositionsBluePrints;
  final Function displayHelp;

  PuzzleScreen(
      {@required this.onSimulationStart,
      @required this.puzzle,
      @required this.initialPositionsBluePrints,
      @required this.displayHelp,
      @required this.grid});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  double heightBar;
  bool notDisplayedYet = true;

  @override
  void initState() {
    super.initState();
    _reset();

  }

  @override
  Widget build(BuildContext context) {
    // --- Set bluePrints --- //
    if (heightBar == null) {
      if (widget.puzzle.bluePrints.isNotEmpty) {
        heightBar = widget
                .puzzle
                .bluePrints[widget.puzzle.bluePrints.keys.first][0]
                .image
                .width +
            10;
        setBluePrintsPosition();
      } else
        heightBar = 0.0;
    }
    return Container(
      child: GestureDetector(
        onDoubleTap: _reset,
        onPanStart: (_) {
          if (notDisplayedYet){
            notDisplayedYet = false;
            widget.displayHelp();
          }
        },
        child: Container(
          color: Colors
              .black26, //Color is necessary if we want the gesture detector to trigger,
          child: Stack(children: buildChildren(context)),
        ),
      ),
    );
  }

  /// Set the initial positions in 'initialPositionsBluePrints' to all
  /// [GameEntity] present in 'bluePrints'.
  void setBluePrintsPosition() {
    widget.puzzle.bluePrints.forEach((String K, List<GameEntity> value) {
      value.forEach((GameEntity gameEntity) {
        gameEntity.position = widget.initialPositionsBluePrints[K].copy();
        if (gameEntity.type == "portal")
          gameEntity.setTwinPortal(gameEntity.position.copy(), gameEntity);
      });
    });
  }



  /// Build a list of Widget to be used as children of a [Stack]
  ///
  /// This is basically used to wrap the [GameEntities] into [Positioned] Widgets
  /// and potentially in [DraggableEntity] Widgets.
  List<Widget> buildChildren(BuildContext context) {
    List<Widget> list = List<Widget>();

    // App bar containing the bluePrints
    list.add(Positioned(
      bottom: 0.0,
      child: Container(
        color: Color(0xFF463E68),
        width: MediaQuery.of(context).size.width,
        height: heightBar,
      ),
    ));

    // Entities
    list.addAll(widget.puzzle.entities.map((item) => entityBuilder(item)));

    // Actions
    list.addAll(widget.puzzle.actions.map((item) => actionBuilder(item)));

    // BluePrints
    widget.puzzle.bluePrints.forEach((_, List<GameEntity> value) =>
        list.addAll(value.map((GameEntity item) => bluePrintBuilder(item))));

    //End of puzzle
    list.add(widget.puzzle.end.positioned());

    //Spaceship
    list.add(widget.puzzle.spaceship.positioned(child: buildSpaceship()));

    return list;
  }

  /// Callback for gameEntities to notify when a user has moved them around
  /// -> Used to move a gameEntity from 'bluePrints' to 'actions'
  /// -> Used to check if [GameEntity] aren't overlapping each other
  /// -> Used to deal with portals logic
  void onDrop(GameEntity gameEntity) {

    // Remove current entity from gri before dropping it
    widget.grid.removeEntity(gameEntity);

    // There was a collision when moving the entity
    if (!widget.grid.addEntity(gameEntity)){
      setState(() {
        _reset();
        alertBox(context, "Don't stack planets on each other please");
      });
      return;
    }

    setState(() {
      /* ---------------------------- *\
              Was in bluePrints
      \* ---------------------------- */
      if (widget.puzzle.bluePrints[gameEntity.type].remove(gameEntity)) {

        // --- If portal -> Need to create portal twin --- //
        if (gameEntity.type == "portal"){
          int newID = ++widget.puzzle.nbGameEntities;

          //Clone
          GameEntity portalTwin = gameEntity.clone();
          portalTwin.ID = newID;

          gameEntity.setTwinID(newID);
          portalTwin.setTwinID(gameEntity.ID);

          gameEntity.setTwinPortal(portalTwin.position.copy(), portalTwin);
          portalTwin.setTwinPortal(gameEntity.position.copy(), gameEntity);
          widget.puzzle.actions.add(gameEntity);
          widget.puzzle.actions.add(portalTwin); // Attention: order has importance

        }
        else
          widget.puzzle.actions.add(gameEntity);
      }
      /* ---------------------------- *\
          Was already in actions
      \* ---------------------------- */
      else{
        // --- If portal -> Need to update exit component with twin's position
        if (gameEntity.type == "portal"){
          // Search for twin to update position
          widget.puzzle.actions.forEach((twin) {
            if (twin.ID == gameEntity.getTwinID()){

              gameEntity.setTwinPortal(twin.position.copy(),twin);
              twin.setTwinPortal(gameEntity.position.copy(), gameEntity);
            }

          } );
        }
      }
    });
  }

  /// Reset the game as it was on start
  /// - Remove all gameEntities from 'actions'
  /// - Put everything back in 'bluePrints' with correct positions
  void _reset() {
    setState(() {
    List<int> IDs = List<int>();
    widget.puzzle.actions.forEach((item) => addAndRemoveTwinPortal(item, IDs));

    widget.puzzle.actions.clear(); //No more bluePrint placed onto the screen
    widget.grid.resetGrid();
    widget.grid.setEntity(widget.puzzle.entities);
    setBluePrintsPosition();
    });
  }

  /// This function adds the given gameEntity to bluePrints.
  ///
  /// In the case of a portal (composed of two gameEntities), both gameEntities
  /// must not be added to bluePrints, but only one.
  /// This check is performed with the IDs argument, which gives the IDs of portals
  /// already added to bluePrints, allowing us not to add a twin portal to bluePrints
  void addAndRemoveTwinPortal(GameEntity gameEntity, List<int> IDs){
    if (gameEntity.type == "portal"){
      if (!IDs.contains(gameEntity.ID)){
        //Twin portal not added yet
        widget.puzzle.bluePrints[gameEntity.type].add(gameEntity);
        IDs.add(gameEntity.getTwinID()); //Don't add twin portal at next pass
      }
    }
    else
      widget.puzzle.bluePrints[gameEntity.type].add(gameEntity);
  }

  /* --------------------------------- *\
            HELPER FUNCTIONS
  \* --------------------------------- */

  /// Determines whether gravity should be displayed or not depending on the type
  /// of the [GameEntity]
  Widget actionBuilder(GameEntity item) {
    Widget child = item.image;
    var gravityField = 0.0;

    if (item.type == "planet") {
      gravityField = item.gravityField;
      child = PlanetWithGravityField(
        gravityField: gravityField * 2,
        entity: item,
      );
    }
    if (item.type == "portal"){
      // Search for twin portal
      var index = 1;
      widget.puzzle.actions.forEach((gameEntity) {
        if (item.ID == gameEntity.getTwinID())
            if (item.position == gameEntity.position)
                index =2;

      });
      child = IndexDisplay(index: index, child: item.image,);
    }

    return DraggableEntity(
      gameEntity: item,
      onDrop: onDrop,
      gravityField: gravityField,
      child: child,
      onLongPress: () => displayHint(GameEntity.info[item.type],"assets/tutos/${item.type}",context, HINT_VIDEO),
    );
  }

  /// Never display gravity
  Widget bluePrintBuilder(GameEntity item) {

    Widget child = item.image;

    if (item.type == "portal") {
      child = IndexDisplay(index: 2, child: item.image,);
    }

    return DraggableEntity(
      gameEntity: item,
      onDrop: onDrop,
      gravityField: 0.0,
      child: child,
      onLongPress: () => displayHint(GameEntity.info[item.type],"assets/tutos/${item.type}",context, HINT_VIDEO),
    );
  }

  Widget buildSpaceship() {
    return Launcher(
      spaceship: widget.puzzle.spaceship,
      start_simulation: widget.onSimulationStart,
      child: widget.puzzle.spaceship.image,
    );
  }

}

/// Determines whether gravity should be displayed or not depending on the type
/// of the [GameEntity]
Widget entityBuilder(GameEntity item) {
  if (item.type == "planet") {
    // Display gravity
    var gravity = item.gravityField;
    return item.positioned(
        gravity: gravity,
        child: PlanetWithGravityField(entity: item, gravityField: gravity * 2));
  } else {
    //No gravity displayed
    if (item.type == "coin")
      return item.positioned(child: GifViewer(gameEntity: item,));
    else
      return item.positioned();
  }
}
