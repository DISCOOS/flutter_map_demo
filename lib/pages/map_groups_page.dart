import 'package:flutter/material.dart';
import 'package:flutter_map_demo/blocs/geometry_bloc.dart';
import 'package:flutter_map_demo/widgets/drawer_widget.dart';
import 'package:flutter_map_demo/widgets/fab_toolbar_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class MapGroupsPage extends StatefulWidget {

  static const String route = 'groups_map';

  MapGroupsPage(
    this.center,
    this.bloc,
    this.baseMaps,{
      Key key,
  }) : super(key: key);

  final String title = 'Map Groups';
  final LatLng center;
  final GeometryBloc bloc;
  final List<LayerOptions> baseMaps;

  @override
  _MapGroupsPageState createState() => _MapGroupsPageState(
      center, bloc, baseMaps
  );
}

class _MapGroupsPageState extends State<MapGroupsPage> {

  _MapGroupsPageState(this.center, this.bloc, this.baseMaps);


  final LatLng center;
  final GeometryBloc bloc;
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
          MapGroupsPage.route
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
      floatingActionButton: FabToolbar(
        buttons: _createDirectActions(),
        toggled: _createToggledActions(),
      )
    );
  }

  List<LayerOptions> _createLayers() {
    List<LayerOptions> layers = <LayerOptions>[baseMaps[_currentMap]];
    layers.addAll([
      GroupLayerOptions(
        group: [
          MarkerLayerOptions(
              rebuild: bloc.onChanged<Marker>(),
              markers: bloc.items<Marker>()
          ),
          CircleLayerOptions(
              rebuild: bloc.onChanged<CircleMarker>(),
              circles: bloc.items<CircleMarker>()
          ),
          PolygonLayerOptions(
              rebuild: bloc.onChanged<Polygon>(),
              polygons: bloc.items<Polygon>()
          ),
          PolylineLayerOptions(
              rebuild: bloc.onChanged<Polyline>(),
              polylines: bloc.items<Polyline>()
          ),
        ],
      )
    ]);
    return layers;
  }

  List<Widget> _createToggledActions() {
    List<Widget> buttons = <Widget>[];

    buttons.addAll([
      Container(
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Add',
          mini: true,
          child: Icon(Icons.add),
        ),
      ),
      Container(
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Image',
          mini: true,
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.image),
        ),
      ),
      Container(
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Inbox',
          mini: true,
          backgroundColor: Colors.greenAccent,
          child: Icon(Icons.inbox),
        ),
      ),
    ]);

    return buttons;
  }

  List<Widget> _createDirectActions() {
    List<Widget> buttons = <Widget>[];

    buttons.addAll([
      Container(
        child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _currentMap = (_currentMap + 1) % 2;
              });
            },
            tooltip: 'Layers',
            mini: true,
            backgroundColor: Colors.white,
            child: Icon(
                Icons.layers,
                color: Colors.black
            ),
          ),
        ),
    ]);

    return buttons;
  }

}

