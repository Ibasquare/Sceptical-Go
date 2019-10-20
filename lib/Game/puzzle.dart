import 'dart:async' show Future;
import 'package:flutter/material.dart';
import '../Game/PhysicalComponents.dart';
import 'dart:convert';
import 'GameEntity.dart';
import '../Helper/util.dart';



class Puzzle {

  // ---- Info part ----- //
  /// Dictionary that tells you if help needs to be provided to the user for
  /// a given galaxy and a given puzzle
  ///
  /// Key: GalaxyPuzzle
  /// Value: the name of the tuto to provide (file in assets/tutos/)
  static final Map<String,String> info = {
    "00": "planet",
    "02": "sponge_planet",
    "10": "asteroid",
    "20": "portal",
  };

  // ====== GameEntities ======= //

  List<GameEntity> entities =
      List<GameEntity>(); // Immutable obstacles (user cannot move them around)
  List<GameEntity> actions =
      List<GameEntity>(); // Obstacles placed on the map by the user
  Map<String, List<GameEntity>> bluePrints = Map<
      String,
      List<
          GameEntity>>(); // Obstacles that can be placed on the map by the user
  List<GameEntity> removed = List<GameEntity>();

  SpaceShipGameEntity spaceship;
  Coordinates start;
  GameEntity end;

  int nbGameEntities = 0;

  /* -------------------------------------------- *\
                LOADING FUNCTIONS
  \* -------------------------------------------- */

  Future<Puzzle> loadPuzzle(BuildContext context, String filePath) async {
    final json = DefaultAssetBundle.of(context).loadString(filePath);
    final Map<String, dynamic> data = JsonDecoder().convert(await json);

    // --- Build GameEntities --- //

    start = Coordinates.fromJson(json: data['start']);

    end = createEndPoint(
        position: Coordinates.fromJson(json: data['end']),
        imageName : "assets/images/end.png",
        type:"end",
        mass: 10000,//TODO Choose mass of end point
    );

    entities.add(end);

    //Spaceship
    spaceship = createSpaceShip(position: Coordinates.fromJson(json: data['start']), v: VelocityClass(0.0, 0.0), mass: 1000, imageName: null, type: "spaceship"); //TODO change

    int ID = 0;

    //Entities
    for (var entity in (data['entities'] as List)) {
      var gameEntity = _readEntityFromJson(entity);
      gameEntity.ID = ID;
      entities.add(gameEntity);
      ID++;
    }

    var i = 0;
    //BluePrints
    for (var entity in (data['actions'] as List)) {
      i++;
      GameEntity gameEntity = _readEntityFromJson(entity);
      gameEntity.ID = ID;
      ID++;

      _checkJson(entity['name']);

      bluePrints[entity['name']] = List<GameEntity>();
      bluePrints[entity['name']].add(gameEntity);

      _checkJson(entity['quantity']);

      for (var nb = 1; nb < entity['quantity']; nb++) {
        var game = gameEntity.clone();
        game.ID = ID;
        bluePrints[entity['name']].add(game);
        ID++;
      }
    }
    nbGameEntities = ID+1; //without end
    return this;
  }

  /// This function will create a [GameEntity] with the appropriate components
  /// based on the JSON format
  GameEntity _readEntityFromJson(Map<String, dynamic> json) {
    String entity = json['name'];

    _checkJson(entity);
    _checkJson(json['position']['x']);
    _checkJson(json['position']['y']);
    _checkJson(json['image']);

    GameEntity gameEntity;

    switch (entity) {
      case 'planet':
        {

          _checkJson(json['mass']);
          gameEntity = createPlanet(
              position:
                  Coordinates(json['position']['x'], json['position']['y']),
              mass: json['mass'],
              imageName: _formatPath(json['image']),
              type: entity);
          break;
        }
      case 'sponge_planet':
        {
          gameEntity = createSpongePlanet(
              position:
                  Coordinates(json['position']['x'], json['position']['y']),
              imageName: _formatPath(json['image']),
              type: entity);
          break;
        }
      case 'portal':
        {
          _checkJson(json['x2']);
          _checkJson(json['y2']);

          gameEntity = createPortal(
              enter:
                  Coordinates(json['position']['x1'], json['position']['y1']),
              exit: Coordinates(json['x2'], json['y2']),
              imageName: _formatPath(json['image']),
              type: entity);
          break;
        }
      case 'asteroids':
        {
          _checkJson(json['x_velocity']);
          _checkJson(json['y_velocity']);

          gameEntity = createAsteroids(
              position:
                  Coordinates(json['position']['x'], json['position']['y']),
              velocity: VelocityClass(json['x_velocity'], json['y_velocity']),
              imageName: _formatPath(json['image']),
              type: entity);
          (gameEntity.physics as AsteroidsPC).setInitialPosition(Coordinates(json['position']['x'], json['position']['y']));
          break;
        }
      case 'coin':
        {
          gameEntity = createGoldCoin(
              position:
                Coordinates(json['position']['x'], json['position']['y']),
              imageName: "assets/images/coin_gif_tran/0.gif",
              type: entity);
          break;
        }
      default:
        {
          throw "Error while loading puzzle. Please try another puzzle";
        }
    }

    return gameEntity;
  }

  String _formatPath(String name) => "assets/planets/$name.png";

  void _checkJson(dynamic json) {
    if(json == null)
      throw "Error while loading puzzle. Please try another puzzle";
  }

}
