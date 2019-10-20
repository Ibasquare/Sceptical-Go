import 'GameEntity.dart';
import 'dart:math';
import '../Helper/util.dart';

// Abstract class of the PhysicalComponent
abstract class PhysicsComponent
{
  // update : update the entity 
  void update(GameEntity self, SpaceShipGameEntity sp);

  // collide : resolve a collision
  void collide(GameEntity self, GameEntity other);

  PhysicsComponent clone(){
    return this;
  }

  // getCollisionZone : return the pixel where the object is located
  List<Tuple<int, int>> getCollisionZone(Coordinates center, double entityRadius);
}

/* ------------------------------------------ *\
                  PORTALS
\* ------------------------------------------ */
class PortalPC extends PhysicsComponent
{
  Coordinates exit; // Position of twin portal
  GameEntity exitGameEntity;
  int twinID; //ID of twin portal
  PortalPC(this.exit);

  @override
  void update(GameEntity self, SpaceShipGameEntity sp)
  {
  }

  void collide(GameEntity self, GameEntity other) {

    other.position = Coordinates(exit.x,exit.y);

    self.hasCollided = true;
    self.collidedID = other.ID;

    exitGameEntity.hasCollided = true;
    exitGameEntity.collidedID = other.ID;

    other.hasCollided = true;
    other.collidedID = exitGameEntity.ID;
  }

  @override
  PhysicsComponent clone() {
    return PortalPC(this.exit.copy());
  }

  @override
  List<Tuple<int, int>> getCollisionZone(Coordinates center ,double entityRadius) {
    return getCirclePixels(center, entityRadius);
  }

}


/* ------------------------------------------ *\
                  PLANET
\* ------------------------------------------ */
class PlanetPC extends PhysicsComponent
{
  var mass;

  PlanetPC(this.mass);

  //Computation of the force to apply to the space ship based on Newton
  //gravity law F= G Mm/r2
  @override
  void update(GameEntity self, SpaceShipGameEntity sp)
  {
    if (!isInRangeForGravity(sp.position, self.position, self.gravityField))
    {
      return;
    }
    var normeFG = G * mass * sp.mass / pow(self.position.distance(sp.position),2);
    var angle = self.position.angle(sp.position);
    sp.forceApplied[0] += normeFG*cos(angle);
    sp.forceApplied[1] +=normeFG*sin(angle);
  }

  void collide(GameEntity self, GameEntity other) {
    other.crash();
  }

  @override
  List<Tuple<int, int>> getCollisionZone(Coordinates center ,double entityRadius) {
    return getCirclePixels(center, entityRadius);
  }

}

bool isInRangeForGravity(Coordinates spaceShip, Coordinates planet, double gravityField)
{
  if(spaceShip.x >= planet.x - gravityField
      && spaceShip.x <= planet.x + gravityField
      && spaceShip.y >= planet.y - gravityField
      && spaceShip.y <= planet.y + gravityField)
    return true;
  return false;
}


/* ------------------------------------------ *\
                  SPONGE PLANET
\* ------------------------------------------ */
class SpongePlanetPC extends PhysicsComponent
{
  var _countBeforeNextCollide;
  bool _canCollide;
  Coordinates _collisionPoint;

  Coordinates get getcollisionPoint => _collisionPoint;
  void setcollisionPoint(Coordinates a) => _collisionPoint = a;

  SpongePlanetPC()
  {
    this._countBeforeNextCollide = 20;
    this._canCollide = true;
  }
  @override
  void update(GameEntity self, SpaceShipGameEntity sp)
  {
    if(!this._canCollide)
    {
      this._countBeforeNextCollide --;
      if(this._countBeforeNextCollide == 0)
      {
       this._canCollide = true;
       this._countBeforeNextCollide = 20;
      }
    }
  }
  //Collide resolution for the spongeplanet.
  //The collision is divided in 4 parts and we wait 20 tick to accept a other
  // colision in order to prevent multi-colision if the spped of the ship is too
  //high
  void collide(GameEntity self, GameEntity other) {
    if (this._canCollide) {
      if (_collisionPoint.x >=
          (self.position.x + self.entityRadius * cos(pi / 4))) {
        other.velocity.inverseX();
        this._canCollide = false;
      }
      else if (_collisionPoint.y <=
          (self.position.y - self.entityRadius * sin(pi / 4))) {
        other.velocity.inverseY();
        this._canCollide = false;
      }
      else if (_collisionPoint.x <=
          (self.position.x + self.entityRadius * cos(3 * pi / 4))) {
        other.velocity.inverseX();
        this._canCollide = false;
      }
      else if (_collisionPoint.y >=
          (self.position.y - self.entityRadius * sin(-pi / 4))) {
        other.velocity.inverseY();
        this._canCollide = false;
      }
    }
  }

  @override
  List<Tuple<int, int>> getCollisionZone(Coordinates center ,double entityRadius) {
    return getCirclePixels(center, entityRadius);
  }

}


/* ------------------------------------------ *\
                  ASTEROIDS
\* ------------------------------------------ */
class AsteroidsPC extends PhysicsComponent
{
  Coordinates initialPosition;
  Coordinates endPosition;

  var deltaT = 0.0;


  void setInitialPosition(Coordinates pos){
    initialPosition = Coordinates(pos.x,pos.y);
  }


  @override
  void update(GameEntity self, SpaceShipGameEntity sp)
  {
    //check if we need to reset position
    if (self.crashed) {
      self.position = Coordinates(initialPosition.x,initialPosition.y);
      self.hasCollided = false;
      self.collidedID = null;
      self.crashed = false;
      self.wasInScreen = false;
    }
    else {
      self.position.x += self.velocity.xVelocity * deltaT;
      self.position.y += self.velocity.yVelocity * deltaT;
    }
  }

  void collide(GameEntity self, GameEntity other) {
    if(other.type != 'asteroids')
      other.collide(self);
  }

  @override
  List<Tuple<int, int>> getCollisionZone(Coordinates center,double entityRadius) {
    return getCirclePixels(center, entityRadius);
  }

}


/* ------------------------------------------ *\
                  END
\* ------------------------------------------ */
class EndPointPC extends PhysicsComponent {
  var mass;

  EndPointPC(this.mass);

  @override
  //We apply a small gravity to the end point in order to help the player.
  void update(GameEntity self, SpaceShipGameEntity sp)
  {
    if (!isInRangeForGravity(sp.position, self.position, self.gravityField))
    {
      return;
    }
    var normeFG = G * mass * sp.mass / pow(self.position.distance(sp.position),2);
    var angle = self.position.angle(sp.position);
    sp.forceApplied[0] += normeFG*cos(angle);
    sp.forceApplied[1] +=normeFG*sin(angle);
  }

  @override
  void collide(GameEntity self, GameEntity other) {
    other.land();
  }

  @override
  List<Tuple<int, int>> getCollisionZone(
      Coordinates center, double entityRadius) {
    return getRectanglePixels(center, entityRadius.floor(), entityRadius.floor());
    // TODO: implement getCollisionZone
  }
}

/* ------------------------------------------ *\
                  GOLD COINS
\* ------------------------------------------ */
class GoldCoinsPC extends PhysicsComponent
{
  bool alreadyCaught = false;

  @override
  void update(GameEntity self, SpaceShipGameEntity sp)
  {
    // No effect on spaceship
  }

  void collide(GameEntity self, GameEntity other) {
    //Other is supposed to be spaceship
    if (other is SpaceShipGameEntity && !alreadyCaught)
      other.coins++;
      alreadyCaught = true;
    self.crash(); // Will be removed from the grid
  }

  @override
  List<Tuple<int, int>> getCollisionZone(Coordinates center ,double entityRadius) {
    return getCirclePixels(center, entityRadius);
  }

}