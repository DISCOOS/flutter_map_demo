import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map_demo/models/geo.dart' as Geo;
import 'package:flutter_map_demo/services/action.dart';
import 'package:flutter_map_demo/services/polyline_service.dart';
import 'package:flutter_map/flutter_map.dart';

class PolylineBloc {

  final PolylineService _service;

  // Marker controller
  final StreamController<Null>
    _onChanged = StreamController<Null>.broadcast();

  // Map from point to marker
  final Map<Geo.Polyline, Polyline> _idx = HashMap<Geo.Polyline, Polyline>();

  // List of markers
  final List<Polyline> _items = <Polyline>[];

  PolylineBloc(this._service) {
    _service.subscribe(_handle);
  }

  /// Get Marker change stream
  Stream<Null> get onChanged => _onChanged.stream;

  /// Get unmodifiable list of markers
  List<Polyline> get items => UnmodifiableListView<Polyline>(_items);

  PolylineBuilder _builder = PolylineBuilder();

  /// Set [PolylineBuilder] instance
  set builder(PolylineBuilder builder) => _builder;


  void _handle(Geo.Polyline points, Action action) {
    if(action == Action.ADDED) {
      var polyline = _builder.build(points);
      _items.add(_idx.putIfAbsent(points, () => polyline));
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

/// Interface for building [Polyline].
///
abstract class PolylineBuilder {

  Polyline build(Geo.Polyline points);

  factory PolylineBuilder() => new DefaultPolylineBuilder();

}

/// Default [PolylineBuilder] implementation.
///
class DefaultPolylineBuilder implements PolylineBuilder {

  @override
  Polyline build(Geo.Polyline polyline) {
    return new Polyline(
        points: polyline.points,
        strokeWidth: 2.0,
        color: Colors.purple);
  }

}
