import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter_map_demo/models/geo.dart' as Geo;
import 'package:flutter_map_demo/services/action.dart';

abstract class CircleService {

  /// Get circles.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Geo.Circle> get circles;

  /// Add a callback that will be called whenever [circles] change.
  void subscribe(CircleServiceCallback listener);

  /// Remove a callback previously added by [subscribe].
  void unsubscribe(CircleServiceCallback listener);

  /// Dispose service resources
  void dispose();

}

/// [CircleService] listener callback function
typedef CircleServiceCallback = void Function(Geo.Circle circle, Action action);


/// [CircleService] with randomly generated circles
class RandomCircleServiceImpl implements CircleService {

  // Maximum number of circles
  final int _maxCount;

  // List of circle with latitude and longitude as coordinates
  final List<Geo.Circle> _circles = <Geo.Circle>[];

  // Set of service subscribers
  final Set<CircleServiceCallback> _subscribers = Set();

  // GeoCircle center
  final _center;

  // Random generator
  final _rnd = Random();

  // Timer for periodic circle creation
  Timer _timer;

  /// Creates an empty circle service.
  RandomCircleServiceImpl(this._center, this._maxCount, int duration) {
    _timer = Timer.periodic(
        Duration(milliseconds: duration), _modifyCircles
    );
  }

  @override
  UnmodifiableListView<Geo.Circle>
    get circles => UnmodifiableListView<Geo.Circle>(_circles);

  @override
  void subscribe(CircleServiceCallback listener) => _subscribers.add(listener);

  @override
  void unsubscribe(CircleServiceCallback listener) => _subscribers.remove(listener);

  @override
  void dispose() {
    _timer.cancel();
    _subscribers.clear();
  }

  @override
  String toString() => "$circles";

  void _modifyCircles(Timer timer) {
    var size = _circles.length;
    if(size > _maxCount) {
      var idx = _rnd.nextInt(size);
      _notifyListeners(_circles.removeAt(idx), Action.REMOVED);
    }
    var circle = _nextCircle(0.04);
    _circles.add(circle);
    _notifyListeners(circle, Action.ADDED);
  }

  Geo.Circle _nextCircle(double max) {
    return Geo.Circle(
      _nextCoord(_center.latitude, max),
      _nextCoord(_center.longitude, max),
      10.0,
    );
  }

  double _nextCoord(double coord, double max) {
    var rnd = _rnd.nextDouble();
    return coord + (_rnd.nextBool() ? rnd * max : -rnd * max);
  }

  void _notifyListeners(Geo.Circle circle, Action action) {
    for (final listener in _subscribers) {
      listener(circle, action);
    }
  }


}
