import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_demo/models/geo.dart' as Geo;
import 'package:flutter_map_demo/services/point_service.dart';
import 'package:flutter_map_demo/services/action.dart';
import 'package:flutter_map/flutter_map.dart';


class MarkerBloc {

  final PointService _service;

  // Marker controller
  final StreamController<Null>
    _onChanged = StreamController<Null>.broadcast();

  // Map from point to marker
  final Map<Geo.Point, Marker> _idx = HashMap<Geo.Point, Marker>();

  // List of markers
  final List<Marker> _items = <Marker>[];

  MarkerBloc(this._service) {
    _service.subscribe(_handle);
  }

  /// Get Marker change stream
  Stream<Null> get onChanged => _onChanged.stream;

  /// Get list of points
  UnmodifiableListView<Geo.Point> get points => _service.points;

  /// Get unmodifiable list of markers
  List<Marker> get items => UnmodifiableListView<Marker>(_items);

  MarkerBuilder _builder = MarkerBuilder();

  /// Set [MarkerBuilder] instance
  set builder(MarkerBuilder builder) => _builder;


  void _handle(Geo.Point point, Action action) {
    if(action == Action.ADDED) {
      var marker = _builder.build(point);
      _items.add(_idx.putIfAbsent(point, () => marker));
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

/// Interface for building [Marker].
///
abstract class MarkerBuilder {

  Marker build(Geo.Point point);

  factory MarkerBuilder() => DefaultMarkerBuilder();

}

/// Default [MarkerBuilder] implementation. Builds an [Container] with a
/// '80x80' [Icons.place] icon.
///
class DefaultMarkerBuilder implements MarkerBuilder {

  @override
  Marker build(Geo.Point point) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: point,
      builder: (ctx) => Container(
        child: Icon(Icons.place),
      ),
    );
  }

}


