import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter_map_demo/models/geo.dart';
import 'package:flutter_map_demo/services/action.dart';

abstract class PointService {

  /// Get points.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Point> get points;

  /// Add a callback that will be called whenever [points] change.
  void subscribe(PointServiceCallback listener);

  /// Remove a callback previously added by [subscribe].
  void unsubscribe(PointServiceCallback listener);

  /// Dispose service resources
  void dispose();

}

/// [PointService] listener callback function
typedef PointServiceCallback = void Function(Point point, Action action);


/// [PointService] with randomly generated points
class RandomPointServiceImpl implements PointService {

  // Maximum number of points
  final int _maxCount;

  // List of point with latitude and longitude as coordinates
  final List<Point> _points = <Point>[];

  // Set of service subscribers
  final Set<PointServiceCallback> _subscribers = Set();

  // GeoPoint center
  final _center;

  // Random generator
  final _rnd = Random();

  // Timer for periodic point creation
  Timer _timer;

  /// Creates an empty point service.
  RandomPointServiceImpl(this._center, this._maxCount, int duration) {
    _timer = Timer.periodic(
        Duration(milliseconds: duration), _modifyPoints
    );
  }

  @override
  UnmodifiableListView<Point>
    get points => UnmodifiableListView(_points);

  @override
  void subscribe(PointServiceCallback listener) => _subscribers.add(listener);

  @override
  void unsubscribe(PointServiceCallback listener) => _subscribers.remove(listener);

  @override
  void dispose() {
    _timer.cancel();
    _subscribers.clear();
  }

  @override
  String toString() => "$points";

  void _modifyPoints(Timer timer) {
    var size = _points.length;
    if(size > _maxCount) {
      var idx = _rnd.nextInt(size);
      _notifyListeners(_points.removeAt(idx), Action.REMOVED);
    }
    var point = _nextPoint(0.04);
    _points.add(point);
    _notifyListeners(point, Action.ADDED);
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

  void _notifyListeners(Point point, Action action) {
    for (final listener in _subscribers) {
      listener(point, action);
    }
  }


}
