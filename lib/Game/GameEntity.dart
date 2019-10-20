import 'package:flutter/material.dart';
import '../Helper/util.dart';
import 'PhysicalComponents.dart';
import 'dart:math';
import 'collision_detection.dart';

/// A game entity is made up of different components.
/// The components that it has determine the behavior of the entity. This allows
/// to change the behaviour of an entity by giving it the component that you want.
///
/// Components:
///   - PhysicsComponent: Will determine the way the entity moves in the game
///                       (includes collision detection)
///
class GameEntity {
  // ---- Info part ----- //
  static final Map<String, String> info = {
    "planet":
        "Place planets on the screen and use their gravity to turn around!",
    "sponge_planet": "Bump into Sponge Planets to deviate your course!",
    "portal":
        "Use portals to teleport from one side of the screen to the other!",
    "asteroid": "Pay attention to asteroids",
  };

  // ----- Rendering part ----- //
  int ID;
  Image image;
  String imageName;
  String type;

  bool crashed = false;
  // --- Used to solve problems of multiple collisions on the same entity
  bool hasCollided = false;
  int collidedID = null;
  bool wasInScreen = false;
  bool hasLand = false;
  int coins = 0;

  // ----- Logic part ----- //
  Coordinates position;
  Coordinates initialPosition;
  VelocityClass velocity;
  VelocityClass initVelocity;
  double entityRadius;
  double gravityField;
  PhysicsComponent physics;


  // ----- Constructor ------ //
  GameEntity(
      {@required imageName,
      @required position,
      velocity,
      @required physics,
      @required type,
      ID,
      entityRadius,
      image}){
    this.imageName = imageName;
    this.position = position;
    this.initialPosition = Coordinates(position.x, position.y);
    this.velocity = velocity;
    this.physics = physics;
    this.type = type;
    this.ID = ID;
    this.wasInScreen = false;
    this.entityRadius = entityRadius;
    this.image = image;
    if(velocity != null)
      this.initVelocity = VelocityClass(velocity.xVelocity,velocity.yVelocity);
  }

  GameEntity clone() {
    return GameEntity(
      imageName: this.imageName,
      position: this.position?.copy(),
      velocity: this.velocity?.copy(),
      physics: this.physics.clone(),
      type: this.type,
      ID: this.ID,
      entityRadius: this.entityRadius,
      image: this.image
    ); //Same ID for portal twins
  }

  /// The entity has an update() method that gets called once per frame by the game.
  void update(GameEntity sp, Grid grid) {
    if(type == "asteroids") {
      if(!grid.screenSize.contains(Offset(position.x+entityRadius,position.y+entityRadius)) && !grid.screenSize.contains(Offset(position.x-entityRadius,position.y-entityRadius))){
        if(wasInScreen){
          if(velocity.xVelocity > 0){
            (physics as AsteroidsPC).initialPosition.x = initialPosition.x + ((position.x-entityRadius) - grid.screenSize.width);
          }
          else if(velocity.xVelocity == 0){
            (physics as AsteroidsPC).initialPosition.x = initialPosition.x;
          }
          else{
            (physics as AsteroidsPC).initialPosition.x = initialPosition.x + ((position.x+entityRadius));
          }

          if(velocity.yVelocity > 0){
            (physics as AsteroidsPC).initialPosition.y = initialPosition.y + ((position.y-entityRadius) - grid.screenSize.height);
          }
          else if(velocity.yVelocity == 0){
            (physics as AsteroidsPC).initialPosition.y = initialPosition.y;
          }
          else{
            (physics as AsteroidsPC).initialPosition.y = initialPosition.y + ((position.y+entityRadius));
          }
          this.crash();
        }
      }
      else{
        wasInScreen = true;
      }
    }
    physics.update(this, sp);
    grid.update(this);
  }

  /// Computes position of Image based on:
  ///  * The radius of the gameEntity
  ///  * (Possibly) the gravity field
  Positioned positioned({Widget child: null, double gravity: 0.0}) {
    var m = gravity;
    if (gravity == 0.0)
      m = entityRadius;

    return Positioned(
      left: position.x - m,
      top: position.y - m,
      child: (child ?? image),
    );
  }

  int getMass() {
    if (type == "planet")
      return (physics as PlanetPC).mass;
    else if (type == "end") {
      return (physics as EndPointPC).mass;
    } else
      return 0;
  }

  void setTwinPortal(Coordinates position, GameEntity exitGameEntity)
  {
    if (type == "portal")
      (physics as PortalPC).exit = position;
      (physics as PortalPC).exitGameEntity = exitGameEntity;
  }

  void setTwinID(int value){
    if (type == "portal")
      (physics as PortalPC).twinID = value;
  }

  int getTwinID(){
    if (type == "portal")
      return (physics as PortalPC).twinID;
  }

  Coordinates getTwinPortal(){
    if (type == "portal" )
      return (physics as PortalPC).exit;
  }

  void collide(GameEntity other) {
    physics.collide(this, other);
  }

  List<Tuple<int, int>> getCollisionZone() {
    return physics.getCollisionZone(position, entityRadius);
  }

  void crash() {
    crashed = true;
  }

  void land() {
    hasLand = true;
  }

  @override
  operator ==(Object object) {
    return identical(object, this);
  }

  bool detectCollision(GameEntity entity){
    bool collided = false;
    this.getCollisionZone().forEach((Tuple<int, int> positions){
      entity.getCollisionZone().forEach((Tuple<int, int> positions2){
        if(positions.tuple1 == positions2.tuple1 && positions.tuple2 == positions2.tuple2){
          collided = true;
          return;
        }
      });
    });
    return collided;
  }

  void reset(){
    if(type == "coin")
      (physics as GoldCoinsPC).alreadyCaught = false;
    if(type == "asteroids"){
      (physics as AsteroidsPC).initialPosition.x = initialPosition.x;
      (physics as AsteroidsPC).initialPosition.y = initialPosition.y;
    }
    if(velocity != null)
      velocity = VelocityClass(initVelocity.xVelocity,initVelocity.yVelocity);

    position = Coordinates(initialPosition.x, initialPosition.y);
    hasCollided = false;
    crashed = false;
    wasInScreen = false;
  }
}

/* -------------------------------------------------------- *\
                  SPACESHIP GAME ENTITY
\* -------------------------------------------------------- */
class SpaceShipGameEntity extends GameEntity {
  var forceApplied = [0.0, 0.0];
  var _mass = 9;
  var max_speed = Offset(250.0,250.0);
  Tuple<double, double> entityDimensions;

  get mass => _mass;

  SpaceShipGameEntity({
    @required imageName,
    @required position,
    velocity,
    @required type,
    ID,
  }) : super(
            imageName: imageName,
            position: position,
            velocity: velocity,
            physics: null,
            type: type,
            ID: ID);

  @override
  void collide(GameEntity other) {
    this.crash();
  }
  //Computation of the position of the spaceship based on the forces applied on him
  void updatePosition(double elapsedTime, Grid grid)
  {
    var deltaT = elapsedTime;

    var a = [forceApplied[0]/_mass,forceApplied[1]/_mass];


    position.x += velocity.xVelocity* deltaT + 0.5 * a[0] * pow(deltaT,2);
    position.y += velocity.yVelocity* deltaT + 0.5 * a[1] * pow(deltaT,2);

    velocity.xVelocity += a[0] * deltaT;
    velocity.yVelocity += a[1] * deltaT;

    var ratio;
    if(velocity.yVelocity != 0 && velocity.xVelocity != 0) {
      ratio = velocity.xVelocity / velocity.yVelocity;

      // ----- Limit acceleration of spaceship for game to remain playable ----- //
      if (velocity.xVelocity > max_speed.dx) {
        velocity.xVelocity = max_speed.dx;
        velocity.yVelocity = max_speed.dy / ratio;
      }
      if (velocity.xVelocity < -max_speed.dx) {
        velocity.xVelocity = -max_speed.dx;
        velocity.yVelocity = -max_speed.dy / ratio;
      }
      if (velocity.yVelocity > max_speed.dy) {
        velocity.yVelocity = max_speed.dy;
        velocity.xVelocity = max_speed.dx*ratio;
      }
      if (velocity.yVelocity < -max_speed.dy) {
        velocity.yVelocity = -max_speed.dy;
        velocity.xVelocity = -max_speed.dx*ratio;
      }

    }
    else if(velocity.xVelocity == 0 && velocity.yVelocity != 0){
      velocity.yVelocity = (velocity.yVelocity>max_speed.dy)?max_speed.dy:velocity.yVelocity;
      velocity.yVelocity = (velocity.yVelocity<-max_speed.dy)?-max_speed.dy:velocity.yVelocity;
    }
    else{
      velocity.xVelocity = (velocity.xVelocity>max_speed.dx)?max_speed.dx:velocity.xVelocity;
      velocity.xVelocity = (velocity.xVelocity<-max_speed.dx)?-max_speed.dx:velocity.xVelocity;
    }

    grid.update(this);
  }

  @override
  List<Tuple<int, int>> getCollisionZone() {
    //L: height, l: width
    //tuple2 is height, tuple1 is width
    return getRectanglePixels(position, entityDimensions.tuple2.floor(),
        entityDimensions.tuple1.floor());
  }

  /// Computes position of Image based on:
  ///  * The radius of the gameEntity
  ///  * (Possibly) the gravity field
  @override
  Positioned positioned({Widget child: null, double gravity: 0.0})
  {
    var m = gravity;
    if (gravity == 0.0)
      m = entityRadius;

    //Computation of the angle to apply to the image 
    if(velocity != null && (velocity.xVelocity != 0.0 || velocity.yVelocity != 0.0))
    {
      var angle;
      if(velocity.xVelocity == 0){
        angle = velocity.yVelocity>0?pi:0.0;
      }
      else if(velocity.yVelocity == 0){
        angle = velocity.xVelocity>0?pi/2:-pi/2;
      }
      else if(velocity.yVelocity > 0 && velocity.xVelocity >0) {
       angle = atan(velocity.yVelocity / velocity.xVelocity) + pi/2;
      }
      else if(velocity.yVelocity < 0 && velocity.xVelocity >0){
        angle = atan(velocity.yVelocity / velocity.xVelocity) + pi/2;
      }
      else if(velocity.yVelocity > 0 && velocity.xVelocity <0){
        angle = atan(velocity.yVelocity / velocity.xVelocity) - pi/2;
      }
      else if(velocity.yVelocity < 0 && velocity.xVelocity <0){
        angle = atan(velocity.yVelocity / velocity.xVelocity) - pi/2;
      }
      else{
        angle = atan(velocity.yVelocity / velocity.xVelocity);
      }
      
      Widget imageRotated = new Transform.rotate(
          angle:(angle),
          child:image);

      return Positioned(
        left: position.x - entityDimensions.tuple1 / 2, //Tuple 1 is width
        top: position.y - entityDimensions.tuple2 / 2, //Tuple 2 is height
        child: imageRotated,
      );
    }

    return Positioned(
      left: position.x - entityDimensions.tuple1 / 2, //Tuple 1 is width
      top: position.y - entityDimensions.tuple2 / 2, //Tuple 2 is height
      child: (child ?? image),
    );
  }
}

// ================================= \\
//        HELPER FUNCTIONS
// ================================= \\

GameEntity createPlanet(
    {@required Coordinates position,
    @required var mass,
    @required String imageName,
    @required String type}) {
  return GameEntity(
      position: position,
      physics: PlanetPC(mass),
      imageName: imageName,
      type: type);
}

GameEntity createPortal(
    {@required Coordinates enter,
    @required Coordinates exit,
    @required String imageName,
    @required String type}) {
  return GameEntity(
      position: enter,
      physics: PortalPC(exit),
      imageName: imageName,
      type: type);
}

GameEntity createSpaceShip(
    {@required Coordinates position,
    @required VelocityClass v,
    @required var mass,
    @required String imageName,
    String type}) {
  return SpaceShipGameEntity(
      position: position, velocity: v, imageName: imageName, type: type);
}

GameEntity createSpongePlanet(
    {@required Coordinates position,
    @required String imageName,
    @required String type}) {
  return GameEntity(
      position: position,
      imageName: imageName,
      physics: SpongePlanetPC(),
      type: type);
}

GameEntity createAsteroids(
    {@required Coordinates position,
    @required String imageName,
    @required VelocityClass velocity,
    @required String type}) {
  return GameEntity(
      position: position, velocity : velocity, imageName: imageName, physics: AsteroidsPC(), type: type);
}

GameEntity createEndPoint(
    {@required Coordinates position,
    @required String imageName,
    @required String type,
    var mass = 0.0}) {
  return GameEntity(
      position: position,
      imageName: imageName,
      physics: EndPointPC(mass),
      type: type,
      ID: -1);
}

GameEntity createGoldCoin(
{@required Coordinates position,
    @required String imageName,
    @required String type}){
  return GameEntity(
    position: position,
    imageName: imageName,
    physics: GoldCoinsPC(),
    type: type,
  );

}
