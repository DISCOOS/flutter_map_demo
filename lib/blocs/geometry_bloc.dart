import 'dart:async';
import 'dart:collection';

import 'package:flutter_map_demo/blocs/circle_bloc.dart';
import 'package:flutter_map_demo/blocs/marker_bloc.dart';
import 'package:flutter_map_demo/blocs/polygon_bloc.dart';
import 'package:flutter_map_demo/blocs/polyline_bloc.dart';
import 'package:flutter_map_demo/models/geo.dart' as Geo;
import 'package:flutter_map_demo/services/action.dart';
import 'package:flutter_map_demo/services/geometry_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';

class GeometryBloc {

  final GeometryService _service;

  // List of stream controllers for geometry changes
  final Map<Type, StreamController<Null>>
    _controllers = Map<Type, StreamController<Null>>();

  // Map from geometry to map element
  final Map<Geo.Geometry, dynamic> _idx = HashMap<Geo.Geometry, dynamic>();

  // List of map elements
  final Map<Type, List<dynamic>> _items = Map<Type,List<dynamic>>();

  GeometryBloc(this._service) {

    _items[Marker] = <Marker>[];
    _items[Polygon] = <Polygon>[];
    _items[Polyline] = <Polyline>[];
    _items[CircleMarker] = <CircleMarker>[];

    _controllers[Marker] = StreamController<Null>.broadcast();
    _controllers[Polygon] = StreamController<Null>.broadcast();
    _controllers[Polyline] = StreamController<Null>.broadcast();
    _controllers[CircleMarker] = StreamController<Null>.broadcast();

    _service.subscribe(_handle);

  }

  /// Get geometry change stream
  Stream<Null> onChanged<T>() => _controllers[T].stream;

  /// Get unmodifiable list of circle markers
  List<T> items<T>() => UnmodifiableListView(_items[T] as Iterable<T>);

  GeometryBuilder _builder = GeometryBuilder();

  /// Set [GeometryBuilder] instance
  set builder(GeometryBuilder builder) => _builder;

  Type _toElementType<T>(T geom) {
    if(geom is Geo.Point) {
      return Marker;
    }
    else if(geom is Geo.Polygon) {
      return Polygon;
    }
    else if(geom is Geo.Polyline) {
      return Polyline;
    }
    else if(geom is Geo.Circle) {
      return CircleMarker;
    }
    throw ("Unknown geometry type: $T");
  }


  void _handle(Geo.Geometry geom, Action action) {
    if(action == Action.ADDED) {
      _onAdded(geom);
    }
    else {
      _onRemoved(geom);
    }
    _controllers[_toElementType(geom)].add(null);
//
//    if(geom is Geo.Point) {
//      _controllers[_toElementType(geom)].add(null);
//    }
//    else if(geom is Geo.Polygon) {
//      _controllers[Polygon].add(null);
//    }
//    else if(geom is Geo.Polyline) {
//      _controllers[Polyline].add(null);
//    }
//    else if(geom is Geo.Circle) {
//      _controllers[CircleMarker].add(null);
//    }
  }

  void _onAdded(Geo.Geometry geom) {
    var element = _builder.build(geom);
    var type = _toElementType(geom);
    _items[type].add(_idx.putIfAbsent(geom, () => element));
//
//    if(element is Marker) {
//      _items[Marker].add(_idx.putIfAbsent(geom, () => element));
//    }
//    else if(element is Polygon) {
//      _items[Polygon].add(_idx.putIfAbsent(geom, () => element));
//    }
//    else if(element is Polyline) {
//      _items[Polyline].add(_idx.putIfAbsent(geom, () => element));
//    }
//    else if(element is CircleMarker) {
//      _items[CircleMarker].add(_idx.putIfAbsent(geom, () => element));
//    }
//    else
//      throw ("Unknown map geometry type for GeometryBloc: $element");
  }

  void _onRemoved(Geo.Geometry geom) {
    var type = _toElementType(geom);
    _items[type].remove(_idx.remove(geom));
//    if(geom is Geo.Point) {
//      _items[Marker].remove(_idx.remove(geom));
//    }
//    else if(geom is Geo.Polygon) {
//      _items[Polygon].remove(_idx.remove(geom));
//    }
//    else if(geom is Geo.Polyline) {
//      _items[Polyline].remove(_idx.remove(geom));
//    }
//    else if(geom is Geo.Circle) {
//      _items[CircleMarker].remove(_idx.remove(geom));
//    }
//    else
//      throw ("Unknown map geometry type for GeometryBloc: $geom");
  }


  /// Take care of closing streams.
  void dispose() {
    _items.clear();
    _service.unsubscribe(_handle);
    _controllers.forEach((_, ctrl) => ctrl.close());
  }

}

/// Interface for building map geometries.
///
abstract class GeometryBuilder {

  dynamic build<T extends Geo.Geometry>(T geom);

  factory GeometryBuilder() => DefaultGeometryBuilder();

}

/// Default [GeometryBuilder] implementation.
///
class DefaultGeometryBuilder implements GeometryBuilder {
  
  GetIt builders = GetIt();

  
  DefaultGeometryBuilder() {
    builders.registerLazySingleton(() => MarkerBuilder());
    builders.registerLazySingleton(() => PolygonBuilder());
    builders.registerLazySingleton(() => PolylineBuilder());
    builders.registerLazySingleton(() => CircleMarkerBuilder());
  }

  @override
  dynamic build<T extends Geo.Geometry>(T geom) {
    if (geom is Geo.Point) {
      return builders.get<MarkerBuilder>().build(geom);
    }
    if (geom is Geo.Polygon) {
      return builders.get<PolygonBuilder>().build(geom);
    }
    if (geom is Geo.Polyline) {
      return builders.get<PolylineBuilder>().build(geom);
    }
    if (geom is Geo.Circle) {
      return builders.get<CircleMarkerBuilder>().build(geom);
    }
  }

}
