import 'package:flutter/material.dart';
import '../Menus/background.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import '../Helper/util.dart';
import 'GameEntity.dart';
import 'PhysicalComponents.dart';

class Grid {
  List<Tuple<List<Tuple<int,int>>,GameEntity>> entities;
  List<List<int>> grid;
  MediaQueryData mediaQueryData;
  Size screenSize;

  /// --------- Grid Constructor --------- //
  Grid({@required List<GameEntity> entities, @required BuildContext context}) {
    //Get information about the current screen being used.
    mediaQueryData = MediaQuery.of(context);
    screenSize = (mediaQueryData.size);

    // --------- Grid Creation --------- //
    grid = List<List<int>>(screenSize.width.ceil());

    for (int i = 0; i < grid.length; i++) {
      grid[i] = List<int>(screenSize.height.ceil());
    }
    // --------- Grid Initialization --------- //
    setEntity(entities);
  }

  /// --------- Grid Initialization Function --------- //
  void setEntity(List<GameEntity> entities){
    this.entities = new List<Tuple<List<Tuple<int,int>>,GameEntity>>();

    entities.forEach((GameEntity entity) {
      List<Tuple<int, int>> positions = entity.getCollisionZone();

      Tuple<List<Tuple<int,int>>,GameEntity> value = new Tuple<List<Tuple<int,int>>,GameEntity>(positions, entity);
      this.entities.add(value);

      positions.forEach((Tuple<int, int> position) {
        movePixel(position.tuple1, position.tuple2, entity);
      });
    });
  }

  /// --------- Grid Reset Function --------- //
  void resetGrid(){
    this.entities.clear();

    // -------- Grid Creation and Initialization -------- //
    grid = List<List<int>>(screenSize.width.ceil());

    for (int i = 0; i < grid.length; i++) {
      grid[i] = List<int>(screenSize.height.ceil());
    }

  }

  /// --------- Return All Hit Boxes of the entities on the grid --------- //
  List<Widget> getHitBoxes(){
    List<Widget> widgets = new List<Widget>();
    this.entities.forEach((Tuple<List<Tuple<int,int>>,GameEntity> entity2){
      List<Tuple<int, int>> positions = entity2.tuple1;
      positions.forEach((Tuple<int, int> position) {
        widgets.add(Star(
          xPos: position.tuple1.toDouble(),
          yPos: position.tuple2.toDouble(),
          permanent: true,
          birthTime: DateTime.now(),
          life_time: 10,
          radius: 1.0,
          color: Colors.blue,
          moving: false,
        ));
      });
    });
    return widgets;
  }

  /// --------- Clean the grid of the given entity --------- //
  /// entity --> entity that will be remove of the grid
  /// newPostions --> newPostion of the given entity on the grid
  void cleanGrid(GameEntity entity, List<Tuple<int, int>> newPositions) {
    this.entities.forEach((Tuple<List<Tuple<int,int>>,GameEntity> entity2){
      if(entity2.tuple2.ID == entity.ID){
        List<Tuple<int, int>> positions = entity2.tuple1;
        positions.forEach((Tuple<int, int> position) {
          if (screenSize.contains(Offset(
              position.tuple1.toDouble(), position.tuple2.toDouble()))) {
            grid[position.tuple1][position.tuple2] = null;
          }
        });
        entity2.tuple1 = newPositions;
      }
    });
  }

  /// --------- Pixel Movement on the grid --------- //
  /// This function allows to move a pixel of a given entity on the grid and to check wether it
  /// will collide with another entity.
  bool movePixel(int x,int y, GameEntity entity, {bool layout : false}) {
    if(entity is SpaceShipGameEntity && (!screenSize.contains(Offset(x.toDouble()+1,y.toDouble())) || !screenSize.contains(Offset(x.toDouble(),y.toDouble()+1)) || !screenSize.contains(Offset(x.toDouble()+1,y.toDouble()+1)))){
      entity.crash();
      return true;
    }
    if(entity.type == "asteroids" && (!screenSize.contains(Offset(x.toDouble()+1,y.toDouble())) || !screenSize.contains(Offset(x.toDouble(),y.toDouble()+1)) || !screenSize.contains(Offset(x.toDouble()+1,y.toDouble()+1)))){
      return false;
    }
    if(!screenSize.contains(Offset(x.toDouble(),y.toDouble()))){
      return false;
    }

    //If another entity is already located on this cell of the grid.
    if (grid[x][y] != null) {
      //Check iff the entity that is colliding has already collided the same entity
      // or
      // in case if the entity is a portal, check if no collision with the twin portal
      if(entity.hasCollided && (entity.collidedID == grid[x][y] || (entity.type == "portal" && (entity.physics as PortalPC).twinID == grid[x][y]))){
        return true;
      }
      this.entities.forEach((Tuple<List<Tuple<int,int>>,GameEntity> entity2){
        // search for the entity who is located on this cell of the grid
        if (grid[x][y] == entity2.tuple2.ID) {
          //Check f the entity that is colliding has already collided the same entity
          // or
          // in case if the entity is a portal, check if no collision with the twin portal
          if(entity2.tuple2.hasCollided && ((entity.ID == entity2.tuple2.collidedID && entity.collidedID == entity2.tuple2.ID) || (entity2.tuple2.type == "portal" && (entity2.tuple2.physics as PortalPC).twinID == entity.ID))) {
            return;
          }
          else if(entity2.tuple2.type == "portal"){
            //print("Entity2 collided with" + entity2.tuple2.collidedID.toString() + grid[x][y].toString() +  "," + (entity2.tuple2.physics as PortalPC).twinID.toString());
          }
            if(entity2.tuple2.type == "sponge_planet")
          {
            (entity2.tuple2.physics as SpongePlanetPC).setcollisionPoint(Coordinates(x.toDouble(), y.toDouble()));
          }

          //In case you only want to check without "colliding"
          if(!layout)
            entity2.tuple2.collide(entity);
          //print("Collision happened between " + entity2.tuple2.type + " and " + entity.type);
          return;
        }
      });
      return true;
    } else {
      grid[x][y] = entity.ID;
      return false;
    }
  }

  /// --------- Entity Removing --------- //
  /// This function allow to remove an entity of the grid.
  void removeEntity(GameEntity entity){
    Tuple<List<Tuple<int,int>>,GameEntity> tmp;
    this.entities.forEach((Tuple<List<Tuple<int,int>>,GameEntity> entity2){
      if(entity2.tuple2.ID == entity.ID){
        tmp = entity2;
        List<Tuple<int, int>> positions = entity2.tuple2.getCollisionZone();
        cleanGrid(entity2.tuple2,positions);
      }
    });
    this.entities.remove(tmp);
  }

  /// --------- Entity Adding --------- //
  /// This function allow to add an entity on the grid.
  bool addEntity(GameEntity newEntity) {
    List<Tuple<int, int>> positions = newEntity.getCollisionZone();
    Tuple<List<Tuple<int,int>>,GameEntity> value = new Tuple<List<Tuple<int,int>>,GameEntity>(positions,newEntity);

    this.entities.add(value);

    bool collision = false;
    positions.forEach((Tuple<int,int> position){
      if(movePixel(position.tuple1, position.tuple2, newEntity,layout: true)){
        cleanGrid(newEntity, positions);
        collision = true;
        return ;
      }
    });

    if(collision)
      this.entities.remove(value);

    return !collision;
  }

  /// --------- Update all pixel of an Entity on the grid --------- //
  /// This will update the collision zone location of an entity on the grid and check for collisions.
  void update(GameEntity entity) {
    List<Tuple<int, int>> positions = entity.getCollisionZone();
    cleanGrid(entity,positions);

    bool collisionhappenned = false;
    positions.forEach((f) {
      if(movePixel(f.tuple1, f.tuple2, entity)){
        collisionhappenned = true;
        return ;
      }
    });
    if(collisionhappenned)
      entity.hasCollided = false;
  }
}
