import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter_map_demo/models/geo.dart';
import 'package:flutter_map_demo/services/action.dart';

abstract class PolylineService {

  /// Get polylines.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Polyline> get polylines;

  /// Add a callback that will be called whenever [polylines] change.
  void subscribe(PolylineServiceCallback listener);

  /// Remove a callback previously added by [subscribe].
  void unsubscribe(PolylineServiceCallback listener);

  /// Dispose service resources
  void dispose();

}

/// [PolylineService] listener callback function
typedef PolylineServiceCallback = void Function(Polyline polyline, Action action);


/// [PolylineService] with randomly generated points
class RandomPolylineServiceImpl implements PolylineService {

  // Maximum number of polylines
  final int _maxCount;

  // List of polylines with GeoPoint as points
  final List<Polyline> _polylines = <Polyline>[];

  // Set of service subscribers
  final Set<PolylineServiceCallback> _subscribers = Set();

  // GeoPoint center
  final _center;

  // Random generator
  final _rnd = Random();

  // Timer for periodic point creation
  Timer _timer;

  /// Creates an empty point service.
  RandomPolylineServiceImpl(this._center, this._maxCount, int duration) {
    _timer = Timer.periodic(
        Duration(milliseconds: duration), _modifyPolylines
    );
  }

  @override
  UnmodifiableListView<Polyline>
    get polylines => UnmodifiableListView<Polyline>(_polylines);

  @override
  void subscribe(PolylineServiceCallback listener) => _subscribers.add(listener);

  @override
  void unsubscribe(PolylineServiceCallback listener) => _subscribers.remove(listener);

  @override
  void dispose() {
    _timer.cancel();
    _subscribers.clear();
  }

  @override
  String toString() => "$polylines";

  void _modifyPolylines(Timer timer) {
    var size = _polylines.length;
    if(size > _maxCount) {
      var idx = _rnd.nextInt(size);
      _notifyListeners(_polylines.removeAt(idx), Action.REMOVED);
    }
    var polyline = _nextPolyline(10);
    _polylines.add(polyline);
    _notifyListeners(polyline, Action.ADDED);
  }

  Polyline _nextPolyline(int max) {

    max = _rnd.nextInt(max);
    List<Point> points = <Point>[];

    for(var i = 0; i < max; i++) {
      points.add(_nextPoint(0.02));
    }

    return Polyline(points);
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

  void _notifyListeners(Polyline polyline, Action action) {
    for (final listener in _subscribers) {
      listener(polyline, action);
    }
  }


}
