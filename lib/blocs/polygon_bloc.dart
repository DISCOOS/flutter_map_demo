import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map_demo/models/geo.dart' as Geo;
import 'package:flutter_map_demo/services/action.dart';
import 'package:flutter_map_demo/services/polygon_service.dart';
import 'package:flutter_map/flutter_map.dart';

class PolygonBloc {

  final PolygonService _service;

  // Marker controller
  final StreamController<Null>
    _onChanged = StreamController<Null>.broadcast();

  // Map from point to marker
  final Map<Geo.Polygon, Polygon> _idx = HashMap<Geo.Polygon, Polygon>();

  // List of markers
  final List<Polygon> _items = <Polygon>[];

  PolygonBloc(this._service) {
    _service.subscribe(_handle);
  }

  /// Get Marker change stream
  Stream<Null> get onChanged => _onChanged.stream;

  /// Get unmodifiable list of markers
  List<Polygon> get items => UnmodifiableListView<Polygon>(_items);

  PolygonBuilder _builder = PolygonBuilder();

  /// Set [PolygonBuilder] instance
  set builder(PolygonBuilder builder) => _builder;


  void _handle(Geo.Polygon points, Action action) {
    if(action == Action.ADDED) {
      var polygon = _builder.build(points);
      _items.add(_idx.putIfAbsent(points, () => polygon));
    }
    else {
      _items.remove(_idx.remove(points));
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

/// Interface for building [Polygon].
///
abstract class PolygonBuilder {

  Polygon build(Geo.Polygon points);

  factory PolygonBuilder() => DefaultPolygonBuilder();

}

/// Default [PolygonBuilder] implementation.
///
class DefaultPolygonBuilder implements PolygonBuilder {

  @override
  Polygon build(Geo.Polygon polygon) {
    return Polygon(
        points: polygon.points,
        borderStrokeWidth: 2.0,
        color: Colors.purple);
  }

}
