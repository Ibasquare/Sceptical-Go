import 'package:flutter/material.dart';
import 'dart:math';

  // ====== Constants ======= //
var G = 0.001;
var GALAXYPOS = [[0.75, -1.4],[-0.6, 0.0],[0.0, 1.5],[0.3, 3.0],[-0.5, 4.5],[0.60, 6.0],[0.0, 7.5],[-0.2, 9.0]];

// ====== Usefull Classes ======= //
class Coordinates
{
  double x;
  double y;

  Coordinates(this.x, this.y);

  @override
  operator ==(Object object) {
    if (object is Coordinates)
      return (this.x == object.x && this.y == object.y);

    return false;
  }
  //Transformation Offset -> Coordinates
  Coordinates.fromOffset(Offset offset):
      this(offset.dx, offset.dy);

  // Reading from json
  Coordinates.fromJson({Map<String, dynamic> json}){
    x = json['x'].toDouble();
    y = json['y'].toDouble();
  }

  Positioned positioned(Widget child)
  {
    return Positioned(
      left: x,
      top: y,
      child: child,
    );
  }

  Coordinates copy()
  {
    return Coordinates(this.x, this.y);
  }

  // Transformation Coordinate -> Offset
  Offset toOffset()
  {
    return new Offset(this.x, this.y);
  }


  printCoord() => print("$x $y");

  // Computation of the Euclidian distance
  distance(Coordinates other)
  {
    return sqrt(pow(x - other.x,2)+pow(y-other.y,2));
  }
  // Angle between two Coordinates
  angle(Coordinates other)
  {
    return atan2( y-other.y,x-other.x);
  }

  operator +(Coordinates other) {
    return Coordinates(this.x + other.x, this.y + other.y);
  }


}

class VelocityClass
{
  double xVelocity;
  double yVelocity;

  VelocityClass(this.xVelocity, this.yVelocity);

  // Reading from json
  VelocityClass.fromJson({Map<String, dynamic> json}){
    xVelocity = json['x'].toInt();
    yVelocity = json['y'].toInt();
  }
  void inverseX()
  {
    this.xVelocity = - this.xVelocity;
  }
  void inverseY()
  {
    this.yVelocity = -this.yVelocity;
  }

  VelocityClass copy()
  {
    return VelocityClass(this.xVelocity, this.yVelocity);
  }

}


class Tuple<T, Y> {
  T tuple1;
  Y tuple2;

  Tuple(this.tuple1, this.tuple2);
}

List<Tuple<int, int>> getCirclePixels(Coordinates center, double radius) {
  List<Tuple<int, int>> indices = new List<Tuple<int, int>>();
  int radiusSquared = (radius * radius).round();
  int width = (radius + center.x).round();
  int height = (radius + center.y).round();

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      double dx = x - center.x;
      double dy = y - center.y;
      double distanceSquared = dx * dx + dy * dy;

      if (distanceSquared <= radiusSquared) {
        indices.add(Tuple<int, int>(x, y));
      }
    }
  }
  return indices;
}

/// Used to wait for 2 futures in FutureBuilders
class MergedFutures {
  final dynamic first;
  final dynamic second;
  final dynamic third;

  MergedFutures({this.first, this.second, this.third});
}

/// L is height
/// l is width
List<Tuple<int, int>> getRectanglePixels(Coordinates center, int L, int l) {
  List<Tuple<int, int>> indices = new List<Tuple<int, int>>();
  int width = (l/2 + center.x).round();
  int height = (L/2 + center.y).round();

  if((center.x - l/2).round() < 0 || (center.y - L/2).round() < 0 ){
    indices.add(Tuple<int,int>(-1,-1));
  }

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      if (x > (center.x - l/2).round() &&
          y > (center.y - L/2).round()){
        indices.add(Tuple<int, int>(x, y));
      }
    }
  }

  return indices;
}



