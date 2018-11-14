import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map_demo/models/geo.dart' as Geo;
import 'package:flutter_map_demo/services/action.dart';
import 'package:flutter_map_demo/services/circle_service.dart';
import 'package:flutter_map/flutter_map.dart';

class CircleBloc {

  final CircleService _service;

  // CircleMarker controller
  final StreamController<Null>
    _onChanged = StreamController<Null>.broadcast();

  // Map from point to circle marker
  final Map<Geo.Circle, CircleMarker> _idx = HashMap<Geo.Circle, CircleMarker>();

  // List of circle markers
  final List<CircleMarker> _items = <CircleMarker>[];

  CircleBloc(this._service) {
    _service.subscribe(_handle);
  }

  /// Get Marker change stream
  Stream<Null> get onChanged => _onChanged.stream;

  /// Get list of points
  UnmodifiableListView<Geo.Circle> get circles => _service.circles;

  /// Get unmodifiable list of markers
  List<CircleMarker> get items => UnmodifiableListView<CircleMarker>(_items);

  CircleMarkerBuilder _builder = CircleMarkerBuilder();

  /// Set [CircleMarkerBuilder] instance
  set builder(CircleMarkerBuilder builder) => _builder;


  void _handle(Geo.Circle point, Action action) {
    if(action == Action.ADDED) {
      var circle = _builder.build(point);
      _items.add(_idx.putIfAbsent(point, () => circle));
    }
    else {
      _items.remove(_idx.remove(point));
    }
    _onChanged.add(null);
  }

  /// Take care of closing streams.
  void dispose() {
    _service.unsubscribe(_handle);
    _onChanged.close();
    _items.clear();
  }

}

/// Interface for building [CircleMarker].
///
abstract class CircleMarkerBuilder {

  CircleMarker build(Geo.Circle point);

  factory CircleMarkerBuilder() => DefaultCircleMarkerBuilder();

}

/// Default [CircleMarkerBuilder] implementation.
///
class DefaultCircleMarkerBuilder implements CircleMarkerBuilder {

  @override
  CircleMarker build(Geo.Circle point) {
    return CircleMarker(
        point: point,
        radius: 15.0,
        color: Colors.green,
        borderStrokeWidth: 4.0,
        borderColor: Colors.cyan,);
  }

}
