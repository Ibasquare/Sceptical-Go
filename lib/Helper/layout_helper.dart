import 'package:flutter/material.dart';
import '../Game/puzzle.dart';
import '../Game/GameEntity.dart';
import 'util.dart';

const SCREEN_WIDTH = 360.0;
const SCREEN_HEIGHT = 598.0;
const SCREEN_IMAGE_SIZE = 50.0;

/// This function takes as argument:
/// - context: used to get size of screen
/// - puzzle: the current puzzle
///
/// This function will modify all gameEntities positions and set image sizes
/// to respect the ratio, depending on the size of the screen
Map<String, Coordinates> layoutPuzzle(BuildContext context, Puzzle puzzle, int spaceship)
{
  //TODO: attention when encoding puzzle: take appbar into account: don't put anything there,
  //TODO: that is to say: 598.0 - heightAppBar, with heightAppBar = 60
  //TODO: Don't put anything in y coordinates [538.0 - 598.0]

  /* ---------------------------------------- *\
              RATIO COMPUTATION
  \* ---------------------------------------- */
  Size constraint = MediaQuery.of(context).size;

  // > 0 : resulting screen is bigger
  // < 0 : resulting screen is smaller
  final widthRatio = constraint.width/SCREEN_WIDTH; //You have to multiply all x by that
  final heightRatio = constraint.height/SCREEN_HEIGHT; //You have to multiply all y by that

  //Find the limiting ratio (the smallest one, that is going to constraint everything)
  var ratio;
  bool widthConstraining;
  if (widthRatio < heightRatio){
    ratio = widthRatio;
    widthConstraining = true;
  }
  else {
    ratio = heightRatio;
    widthConstraining = false;
  }
  final imageSize = SCREEN_IMAGE_SIZE * ratio;


  /* ---------------------------------------- *\
                    SPACESHIP
  \* ---------------------------------------- */
  var spaceshipWidth = (imageSize/200)*130;
  var spaceshipHeight = imageSize;
  puzzle.spaceship.image = Image.asset("assets/spaceships/space$spaceship.png", width: spaceshipWidth, height: spaceshipHeight,);
  puzzle.spaceship.entityDimensions = Tuple<double, double>(spaceshipWidth, spaceshipHeight); //TODO -20 not working!!


  /* ---------------------------------------- *\
                    ENTITIES
  \* ---------------------------------------- */
  // Apply constraining ratio to everything
  // Add padding for the non-constraining parameter for the game to be centered
  puzzle.entities.forEach((GameEntity gameEntity){

    // ----- Positions ----- //
    gameEntity.position.x *= ratio;
    gameEntity.position.y *= ratio;

    // Add padding to height
    if(widthConstraining){
      var padding = constraint.height / 2 - (SCREEN_HEIGHT * ratio )/2;
      gameEntity.position.y += padding;
    }
    // Add padding to the width
    else{
      var padding = constraint.width /2 - (SCREEN_WIDTH * ratio)/2;
      gameEntity.position.x += padding;
    }

    // ----- Images ----- //
    if(gameEntity.imageName != null){
      gameEntity.image = Image.asset(gameEntity.imageName, width: imageSize, height: imageSize,);
      gameEntity.entityRadius = imageSize/2;
    }

    setGravityField(gameEntity, ratio);

  });

  /* ---------------------------------------- *\
                    BLUEPRINTS
  \* ---------------------------------------- */
  // ---- Compute initial bluePrints positions, according to their number ---- //
  // initial Positions for each type of bluePrint
  Map<String, Coordinates> initialPositionsBluePrints =
  Map<String, Coordinates>();


  int nbBluePrints = puzzle.bluePrints.length;

  var heightBar = imageSize + 10;

  //Compute horizontal positions for each type of bluePrint
  double len = constraint.width / nbBluePrints;
  var firstPosition = 0 + len / 2;

  List<double> positions = List<double>();
  for (int i = 0; i < nbBluePrints; i++)
    positions.add(i * len + firstPosition);

  //Iterate over the number of entries
  var entries = puzzle.bluePrints.entries.toList();
  for (int i = 0; i < entries.length; i++) {
    initialPositionsBluePrints[entries[i].key] = Coordinates(
      positions[i], constraint.height - heightBar / 2);
  }

  // ----- Images ----- //
  puzzle.bluePrints.forEach((String key, List<GameEntity> value) {
    value.forEach((GameEntity gameEntity){
      gameEntity.image = Image.asset(gameEntity.imageName, width: imageSize, height: imageSize,);
      gameEntity.entityRadius = imageSize/2;

      setGravityField(gameEntity, ratio);

    });
  });


  return initialPositionsBluePrints;

}

void setGravityField(GameEntity gameEntity, double ratio){
  // ---- Gravity field ---- //
  if (gameEntity.type == "planet" || gameEntity.type == "end"){
    var gravityField = _fromMassToGravityField(gameEntity.getMass().toDouble());
    gravityField *= ratio;
    gameEntity.gravityField = gravityField;
  }
}

const MASS_LOWER_BOUND = 100000000;
const MASS_UPPER_BOUND = 900000000;

const GRAVITY_LOWER_BOUND = 50;
const GRAVITY_UPPER_BOUND = 150;

double _fromMassToGravityField(double mass){
  mass = mass - MASS_LOWER_BOUND;

  var gravity = mass/(MASS_UPPER_BOUND - MASS_LOWER_BOUND) * (GRAVITY_UPPER_BOUND - GRAVITY_LOWER_BOUND);

  gravity += GRAVITY_LOWER_BOUND;

  // Transpose interval
  var middleInterval = GRAVITY_LOWER_BOUND + (GRAVITY_UPPER_BOUND - GRAVITY_LOWER_BOUND)/2;
  var z = middleInterval - gravity;
  return middleInterval + z;
}