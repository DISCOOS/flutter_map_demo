import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_demo/blocs/geometry_bloc.dart';
import 'package:flutter_map_demo/plugins/GeometryLayer.dart';
import 'package:flutter_map_demo/plugins/MyLocation.dart';
import 'package:flutter_map_demo/widgets/drawer_widget.dart';
import 'package:flutter_map_demo/widgets/fab_toolbar_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
//import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:sensors/sensors.dart';


class MapPluginsPage extends StatefulWidget {

  static const String route = 'plugins_map';

  MapPluginsPage(
      this.center,
      this.bloc,
      this.baseMaps,{
        Key key,
      }) : super(key: key);

  final String title ="Map Plugins";
  final LatLng center;
  final GeometryBloc bloc;
  final List<LayerOptions> baseMaps;

  @override
  _MapPluginsPageState createState() => _MapPluginsPageState(
      center, bloc, baseMaps
  );
}

class _MapPluginsPageState extends State<MapPluginsPage> {

  _MapPluginsPageState(this.center, this.bloc, this.baseMaps);

  final LatLng center;
  final GeometryBloc bloc;
  final List<LayerOptions> baseMaps;
  final Location locationSensor = Location();

  final StreamController<Null> onLocationChanged =
    StreamController.broadcast();

  final List<StreamSubscription<dynamic>> subscriptions =
    <StreamSubscription<dynamic>>[];

  int _currentMap = 0;
  MapController mapController;
  MyLocationOptions locationOpts;

  List<double> location = <double>[];
  List<double> rotation = <double>[];
  List<double> gyroscope = <double>[];
  List<double> accelerometer = <double>[];

  // Timer for batch-based tracking
  Timer periodic;

  // Tracking control flag
  bool tracking = false;


  @override
  void initState() {
    super.initState();
    mapController = MapController();
    locationOpts = MyLocationOptions(
        center,
        onLocationChanged.stream,
    );
    _registerSensors();

    // Start batching location updates
    periodic = Timer.periodic(Duration(milliseconds: 500), (_) {
      _updateLocation(false);
    });

  }

  @override
  void dispose() {
    super.dispose();
    periodic?.cancel();
    onLocationChanged.close();
    for (StreamSubscription<dynamic> subscription in subscriptions) {
      subscription.cancel();
    }
  }

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
          MapPluginsPage.route
      ), // Drawer
      body: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: 12.0,
          maxZoom: 18.0,
          minZoom: 1.0,
          plugins: [
            MyLocation(),
            GeometryLayer(),
          ],
        ),
        layers: _createLayers(),
        mapController: mapController,
      ),
      floatingActionButton: FabToolbar(
        buttons: _createDirectActions(),
        toggled: _createToggledActions(),
      ),
    );
  }

  List<LayerOptions> _createLayers() {
    List<LayerOptions> layers = <LayerOptions>[baseMaps[_currentMap]];
    layers.addAll([
      GeometryLayerOptions(
        markers: MarkerLayerOptions(
            rebuild: bloc.onChanged<Marker>(),
            markers: bloc.items<Marker>()
        ),
        circles: CircleLayerOptions(
            rebuild: bloc.onChanged<CircleMarker>(),
            circles: bloc.items<CircleMarker>()
        ),
        polygons: PolygonLayerOptions(
            rebuild: bloc.onChanged<Polygon>(),
            polygons: bloc.items<Polygon>()
        ),
        polylines: new PolylineLayerOptions(
            rebuild: bloc.onChanged<Polyline>(),
            polylines: bloc.items<Polyline>()
        ),
      ),
      locationOpts,
    ]);
    return layers;
  }

  List<Widget> _createDirectActions() {
    List<Widget> buttons = <Widget>[];

    buttons.addAll([
      Container(
        child: FloatingActionButton(
          onPressed: _toggleMap,
          tooltip: 'Layers',
          mini: true,
          backgroundColor: Colors.white,
          child: Icon(
              Icons.layers,
              color: Colors.black
          ),
        ),
      ),
      Container(
        child: FloatingActionButton(
          onPressed: _locateMe,
          tooltip: 'Locate me',
          mini: true,
          backgroundColor: Colors.white,
          child: Icon(
              Icons.my_location,
              color: Colors.black
          ),
        ),
      )
    ]);

    return buttons;
  }

  List<Widget> _createToggledActions() {
    List<Widget> buttons = <Widget>[];

    buttons.addAll([
      Container(
        child: FloatingActionButton(
          onPressed: () => _moveTo(center),
          tooltip: 'Home',
          mini: true,
          child: Icon(Icons.home),
        ),
      ),
      Container(
        child: FloatingActionButton(
          onPressed: _toggleTracking,
          tooltip: 'Tracking',
          mini: true,
          backgroundColor: tracking ? Colors.red : Colors.green,
          child: Icon(Icons.center_focus_weak),
        ),
      ),
    ]);

    return buttons;
  }

  void _toggleMap() {
    setState(() {
      _currentMap = (_currentMap + 1) % 2;
    });
  }

  void _toggleTracking() {
    setState(() {
      tracking = !tracking;
      locationOpts.color = tracking ? Colors.red : Colors.green;
    });
  }

  void _locateMe() async {
    try {

      location = _toLocation(await locationSensor.getLocation());

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        print('Permission denied - please ask the user to enable it from the app settings');
      }
    }

    _updateLocation(true);

  }

  List<double> _toLocation(Map<String, double> location) {
    Map<String, double> current = location;
    return List.from([current["latitude"], current["longitude"]]);
  }

  void _moveTo(LatLng center) {
    locationOpts.point = center;
    mapController.move(center, 14.0);
  }

  void _updateLocation(bool force) {

    if(mapController.ready) {
      locationOpts.bearing = _calculateBearing();

      // Full refresh of map needed?
      if(force || tracking && _isMoved()) {
        _moveTo(new LatLng(location[0], location[1]));
      } else {
        onLocationChanged.add(null);
      }
    }
  }

  bool _isMoved() {

    return locationOpts.point == null || location.isNotEmpty && (
        (locationOpts.point.latitude - location[0]).abs() > 0.0001 ||
        (locationOpts.point.longitude - location[1]).abs() >  0.0001 ||
        (mapController.center.latitude - location[0]).abs() >  0.0001  ||
        (mapController.center.longitude - location[1]).abs() >  0.0001
    );
  }


  double _calculateBearing() {
//    accelerationX = (signed int)(((signed int)rawData_X) * 3.9);
//    accelerationY = (signed int)(((signed int)rawData_Y) * 3.9);
//    accelerationZ = (signed int)(((signed int)rawData_Z) * 3.9);
//    pitch = 180 * atan (accelerationX/sqrt(accelerationY*accelerationY + accelerationZ*accelerationZ))/M_PI;
//    roll = 180 * atan (accelerationY/sqrt(accelerationX*accelerationX + accelerationZ*accelerationZ))/M_PI;
//    yaw = 180 * atan (accelerationZ/sqrt(accelerationX*accelerationX + accelerationZ*accelerationZ))/M_PI;
//      myLocation.bearing = (event.x - 0.0) / (event.y - 0.0) * 180 / pi;

    return gyroscope.isEmpty ? 0.0 :
      (gyroscope[0] - 0.0) / (gyroscope[1] - 0.0) * 180 / pi;
  }

  void _registerSensors() {
    subscriptions.add(locationSensor.onLocationChanged().listen(
      (Map<String, double> current) {
        location = _toLocation(current);
      }));
    subscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      gyroscope = <double>[event.x, event.y, event.z];
    }));

//    subscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
//      accelerometer = <double>[event.x, event.y, event.z];
//    });
//    gyroscope =  AeyriumSensor.sensorEvents.listen((SensorEvent event) {
//      //do something with the event , values expressed in radians
//      print("Pitch ${event.pitch} and Roll ${event.roll}")
//
//    });
  }

}

