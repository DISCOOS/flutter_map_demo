import 'package:flutter/material.dart';
import 'package:flutter_map_demo/blocs/circle_bloc.dart';
import 'package:flutter_map_demo/blocs/marker_bloc.dart';
import 'package:flutter_map_demo/blocs/polygon_bloc.dart';
import 'package:flutter_map_demo/blocs/polyline_bloc.dart';
import 'package:flutter_map_demo/widgets/drawer_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong/latlong.dart';

class MapOverlaysPage extends StatefulWidget {

  static const String route = 'overlays_map';

  MapOverlaysPage(
    this.center,
    this.services,
    this.baseMaps,{
      Key key,
  }) : super(key: key);

  final String title ="Map Layers";
  final LatLng center;
  final GetIt services;
  final List<LayerOptions> baseMaps;

  @override
  _MapOverlaysPageState createState() => _MapOverlaysPageState(
      center, services, baseMaps
  );
}

class _MapOverlaysPageState extends State<MapOverlaysPage> {

  _MapOverlaysPageState(this.center, this.services, this.baseMaps);

  final LatLng center;
  final GetIt services;
  final List<LayerOptions> baseMaps;

  int _currentMap = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: buildDrawer(
          context,
          MapOverlaysPage.route
      ), // Drawer
      body: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: 12.0,
          maxZoom: 18.0,
          minZoom: 1.0,
        ),
        layers: _createLayers(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentMap = (_currentMap + 1) % 2;
          });
        },
        tooltip: 'Switch layers',
        child: Icon(Icons.layers),
      ),
    );
  }

  List<LayerOptions> _createLayers() {
    List<LayerOptions> layers = <LayerOptions>[baseMaps[_currentMap]];
    layers.addAll([
      PolygonLayerOptions(
          rebuild: services<PolygonBloc>().onChanged,
          polygons: services<PolygonBloc>().items
      ),
      PolylineLayerOptions(
          rebuild: services<PolylineBloc>().onChanged,
          polylines: services<PolylineBloc>().items
      ),
      CircleLayerOptions(
          rebuild: services<CircleBloc>().onChanged,
          circles: services<CircleBloc>().items
      ),
      MarkerLayerOptions(
          rebuild: services<MarkerBloc>().onChanged,
          markers: services<MarkerBloc>().items
      )
    ]);
    return layers;
  }

}

