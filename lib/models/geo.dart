
import 'dart:collection';

import 'package:latlong/latlong.dart';

abstract class Geometry {

}


class Point extends LatLng implements Geometry {
  Point(double latitude, double longitude) : super(latitude, longitude);
}

class Circle extends LatLng implements Geometry {
  double radius;
  Circle(double latitude, double longitude, this.radius)
      : super(latitude, longitude);
}

class Polygon implements Geometry {

  List<Point> _points;

  List<Point> get points => _points;

  set points(List<Point> items) => UnmodifiableListView(_points);

  Polygon(this._points);
}

class Polyline implements Geometry {

  List<Point> _points;

  List<Point> get points => _points;

  set points(List<Point> items) => UnmodifiableListView(_points);

  Polyline(this._points);
}

