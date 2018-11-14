import 'dart:collection';

import 'package:flutter_map_demo/models/geo.dart' as Geo;
import 'package:flutter_map_demo/services/action.dart';
import 'package:flutter_map_demo/services/circle_service.dart';
import 'package:flutter_map_demo/services/point_service.dart';
import 'package:flutter_map_demo/services/polygon_service.dart';
import 'package:flutter_map_demo/services/polyline_service.dart';
import 'package:get_it/get_it.dart';

abstract class GeometryService {

  /// Get points.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Geo.Point> get points;

  /// Get circle.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Geo.Circle> get circles;

  /// Get polylines.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Geo.Polyline> get polylines;

  /// Get polygons.
  /// It is unmodifiable cause we don't want a random widget to
  /// put the service in a bad state
  UnmodifiableListView<Geo.Polygon> get polygons;

  /// Add a callback that will be called whenever [geometries] change.
  void subscribe(GeometryServiceCallback listener);

  /// Remove a callback previously added by [subscribe].
  void unsubscribe(GeometryServiceCallback listener);

  /// Dispose service resources
  void dispose();

}

/// [GeometryService] listener callback function
typedef GeometryServiceCallback = void Function(Geo.Geometry geometry, Action action);


/// [GeometryService] with randomly generated geometries
class RandomGeometryServiceImpl implements GeometryService {

  // List of points
  final List<Geo.Point> _points = <Geo.Point>[];

  // List of cicles
  final List<Geo.Circle> _circles = <Geo.Circle>[];

  // List of polygons
  final List<Geo.Polygon> _polygons = <Geo.Polygon>[];

  // List of polylines
  final List<Geo.Polyline> _polylines = <Geo.Polyline>[];

  // Set of service subscribers
  final Set<GeometryServiceCallback> _subscribers = Set();

  // Service locator
  final GetIt services;

  /// Creates an empty geometry service.
  RandomGeometryServiceImpl(this.services) {
    services<RandomPointServiceImpl>().subscribe(_notifyListeners);
    services<RandomCircleServiceImpl>().subscribe(_notifyListeners);
    services<RandomPolygonServiceImpl>().subscribe(_notifyListeners);
    services<RandomPolylineServiceImpl>().subscribe(_notifyListeners);
  }

  @override
  UnmodifiableListView<Geo.Point>
    get points => UnmodifiableListView<Geo.Point>(_points);

  @override
  UnmodifiableListView<Geo.Circle>
    get circles => UnmodifiableListView<Geo.Circle>(_circles);

  @override
  UnmodifiableListView<Geo.Polygon>
    get polygons => UnmodifiableListView<Geo.Polygon>(_polygons);

  @override
  UnmodifiableListView<Geo.Polyline>
    get polylines => UnmodifiableListView<Geo.Polyline>(_polylines);


  @override
  void subscribe(GeometryServiceCallback listener) => _subscribers.add(listener);

  @override
  void unsubscribe(GeometryServiceCallback listener) => _subscribers.remove(listener);

  @override
  void dispose() {
    _subscribers.clear();
  }

  @override
  String toString() => "[$points,$circles,$polygons,$polylines]";

  void _notifyListeners(Geo.Geometry geometry, Action action) {

    if(action == Action.ADDED) {
      _onAdded(geometry);
    }
    else if(action == Action.REMOVED) {
      _onRemoved(geometry);
    }
    else
      throw ("Unknown action type for GeometryService: $action");

    for (final listener in _subscribers) {
      listener(geometry, action);
    }
  }

  void _onAdded(Geo.Geometry geometry) {
    if(geometry is Geo.Point) {
      _points.add(geometry);
    }
    else if(geometry is Geo.Circle) {
      _circles.add(geometry);
    }
    else if(geometry is Geo.Polygon) {
      _polygons.add(geometry);
    }
    else if(geometry is Geo.Polyline) {
      _polylines.add(geometry);
    }
    else
      throw ("Unknown geometry type for GeometryService: $geometry");
  }

  void _onRemoved(Geo.Geometry geometry) {
    if(geometry is Geo.Point) {
      _points.remove(geometry);
    }
    else if(geometry is Geo.Circle) {
      _circles.remove(geometry);
    }
    else if(geometry is Geo.Polygon) {
      _polygons.remove(geometry);
    }
    else if(geometry is Geo.Polyline) {
      _polylines.remove(geometry);
    }
    else
      throw ("Unknown geometry type for GeometryService: $geometry");
  }

}
