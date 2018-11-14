import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';


class GeometryLayerOptions extends LayerOptions {

  MarkerLayerOptions markers;
  CircleLayerOptions circles;
  PolygonLayerOptions polygons;
  PolylineLayerOptions polylines;

  GeometryLayerOptions({
    this.markers,
    this.circles,
    this.polygons,
    this.polylines});
}

class GeometryLayer implements MapPlugin {

  @override
  bool supportsLayer(LayerOptions options) {
    return options is GeometryLayerOptions;
  }

  @override
  Widget createLayer(LayerOptions options, MapState mapState, Stream<Null> stream) {

    if (options is GeometryLayerOptions) {
      var layers = <Widget>[];
      if (options.markers != null) {
        layers.add(MarkerLayer(
            options.markers, mapState, options.markers.rebuild)
        );
      }
      if (options.circles is CircleLayerOptions) {
        layers.add(CircleLayer(
            options.circles, mapState, options.circles.rebuild)
        );
      }
      if (options.polylines is PolylineLayerOptions) {
        layers.add(PolylineLayer(
            options.polylines, mapState, options.polylines.rebuild)
        );
      }
      if (options.polygons is PolygonLayerOptions) {
        layers.add(PolygonLayer(
            options.polygons, mapState, options.polygons.rebuild)
        );
      }

      return Container(
        child: Stack(
          children: layers,
        ),
      );

    }
    throw ("Unknown options type for GeometryLayer: $options");

  }

}