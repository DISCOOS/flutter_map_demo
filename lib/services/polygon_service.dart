import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter_map_demo/models/geo.dart';
import 'package:flutter_map_demo/services/action.dart';

abstract class PolygonService {

  /// Get polygons.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Polygon> get polygons;

  /// Add a callback that will be called whenever [polygons] change.
  void subscribe(PolygonServiceCallback listener);

  /// Remove a callback previously added by [subscribe].
  void unsubscribe(PolygonServiceCallback listener);

  /// Dispose service resources
  void dispose();

}

/// [PolygonService] listener callback function
typedef PolygonServiceCallback = void Function(Polygon polygon, Action action);


/// [PolygonService] with randomly generated points
class RandomPolygonServiceImpl implements PolygonService {

  // Maximum number of polygons
  final int _maxCount;

  // List of polygons with GeoPoint as points
  final List<Polygon> _polygons = <Polygon>[];

  // Set of service subscribers
  final Set<PolygonServiceCallback> _subscribers = Set();

  // GeoPoint center
  final _center;

  // Random generator
  final _rnd = Random();

  // Timer for periodic point creation
  Timer _timer;

  /// Creates an empty point service.
  RandomPolygonServiceImpl(this._center, this._maxCount, int duration) {
    _timer = Timer.periodic(
        Duration(milliseconds: duration), _modifyPolygons
    );
  }

  @override
  UnmodifiableListView<Polygon>
    get polygons => UnmodifiableListView<Polygon>(_polygons);

  @override
  void subscribe(PolygonServiceCallback listener) => _subscribers.add(listener);

  @override
  void unsubscribe(PolygonServiceCallback listener) => _subscribers.remove(listener);

  @override
  void dispose() {
    _timer.cancel();
    _subscribers.clear();
  }

  @override
  String toString() => "$polygons";

  void _modifyPolygons(Timer timer) {
    var size = _polygons.length;
    if(size > _maxCount) {
      var idx = _rnd.nextInt(size);
      _notifyListeners(_polygons.removeAt(idx), Action.REMOVED);
    }
    var polygon = _nextPolygon(10);
    _polygons.add(polygon);
    _notifyListeners(polygon, Action.ADDED);
  }

  Polygon _nextPolygon(int max) {

    max = _rnd.nextInt(max);
    List<Point> points = <Point>[];

    for(var i = 0; i < max; i++) {
      points.add(_nextPoint(0.02));
    }

    return Polygon(points);
  }


  Point _nextPoint(double max) {
    return Point(
        _nextCoord(_center.latitude, max),
        _nextCoord(_center.longitude, max)
    );
  }

  double _nextCoord(double coord, double max) {
    var rnd = _rnd.nextDouble();
    return coord + (_rnd.nextBool() ? rnd * max : -rnd * max);
  }

  void _notifyListeners(Polygon polygon, Action action) {
    for (final listener in _subscribers) {
      listener(polygon, action);
    }
  }


}
