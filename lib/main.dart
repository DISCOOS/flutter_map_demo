import 'package:flutter/material.dart';
import 'package:flutter_map_demo/blocs/circle_bloc.dart';
import 'package:flutter_map_demo/blocs/geometry_bloc.dart';
import 'package:flutter_map_demo/blocs/marker_bloc.dart';
import 'package:flutter_map_demo/blocs/polygon_bloc.dart';
import 'package:flutter_map_demo/blocs/polyline_bloc.dart';
import 'package:flutter_map_demo/pages/map_groups_page.dart';
import 'package:flutter_map_demo/pages/map_offline_page.dart';
import 'package:flutter_map_demo/pages/map_overlays_page.dart';
import 'package:flutter_map_demo/pages/map_plugins_page.dart';
import 'package:flutter_map_demo/services/circle_service.dart';
import 'package:flutter_map_demo/services/geometry_service.dart';
import 'package:flutter_map_demo/services/point_service.dart';
import 'package:flutter_map_demo/services/polygon_service.dart';
import 'package:flutter_map_demo/services/polyline_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:get_it/get_it.dart';

final _services = GetIt();
GetIt get services => _services;

final _left = LatLng(59.91, 10.74);
LatLng get left => _left;

final _center = LatLng(59.91, 10.76);
LatLng get center => _center;

final _right = LatLng(59.91, 10.78);
LatLng get right => _right;

final _top = LatLng(59.93, 10.76);
LatLng get top => _top;

final _bottom = LatLng(59.88, 10.76);
LatLng get bottom => _bottom;

final baseMaps = <LayerOptions>[
  TileLayerOptions(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: ['a', 'b', 'c']
  ),
  TileLayerOptions(
      urlTemplate: "http://{s}.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=topo4&zoom={z}&x={x}&y={y}",
      subdomains: ['opencache', 'opencache2', 'opencache3']
  )
];

void main() {

  // Register services with service locator
  final pointService = RandomPointServiceImpl(center, 50, 200);
  final polygonService = RandomPolygonServiceImpl(left, 10, 1000);
  final polylineService = RandomPolylineServiceImpl(right, 10, 1000);
  final circleService = RandomCircleServiceImpl(top, 10, 1000);

  services.registerSingleton(pointService);
  services.registerSingleton(polygonService);
  services.registerSingleton(polylineService);
  services.registerSingleton(circleService);
  final geometryService = RandomGeometryServiceImpl(services);

  services.registerSingleton<MarkerBloc>(MarkerBloc(pointService));
  services.registerSingleton<PolygonBloc>(PolygonBloc(polygonService));
  services.registerSingleton<PolylineBloc>(PolylineBloc(polylineService));
  services.registerSingleton<CircleBloc>(CircleBloc(circleService));
  services.registerSingleton<GeometryBloc>(GeometryBloc(geometryService));

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Map PoC',
      home: MapOfflinePage(
        center, services<GeometryBloc>()
    ),
      routes: <String, WidgetBuilder>{
        MapGroupsPage.route: (context) => MapGroupsPage(
          center, services<GeometryBloc>(), baseMaps
        ),
        MapOverlaysPage.route: (context) => MapOverlaysPage(
            center, services, baseMaps
        ),
        MapPluginsPage.route: (context) => MapPluginsPage(
            center, services<GeometryBloc>(), baseMaps
        ),
        MapOfflinePage.route: (context) => MapOfflinePage(
            center, services<GeometryBloc>()
        ),
      }
    );
  }
}
