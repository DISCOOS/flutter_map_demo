import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map_demo/blocs/geometry_bloc.dart';
import 'package:flutter_map_demo/widgets/drawer_widget.dart';
import 'package:flutter_map_demo/widgets/fab_toolbar_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_mbtiles_extractor/mbtiles_extractor.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class MapOfflinePage extends StatefulWidget {
  static const String route = 'offline_map';

  static const String mbtiles =
      'https://www.dropbox.com/s/rlo2frhruonv8j6/oslo.mbtiles?dl=1';
//  static const String mbtiles_comp = 'https://www.dropbox.com/s/9gxpv8fm1z31ip0/oslo-compression.mbtiles?dl=1';
//  static const String mbtiles_tms = 'https://www.dropbox.com/s/yl0ztkhvgvacopm/oslo-tms.mbtiles?dl=1';
//  static const String mbtiles_hq = 'https://www.dropbox.com/s/2e7pkt7p058eaqc/oslo-hq.mbtiles?dl=1';
//  static const String mbtiles_slippy = 'https://www.dropbox.com/s/yl0ztkhvgvacopm/oslo-tms.mbtiles?dl=1';

  MapOfflinePage(
    this.center,
    this.bloc, {
    Key key,
  }) : super(key: key);

  final String title = 'Offline Map';
  final LatLng center;
  final GeometryBloc bloc;

  @override
  _MapOfflinePageState createState() => _MapOfflinePageState(center, bloc);
}

class _MapOfflinePageState extends State<MapOfflinePage> {
  _MapOfflinePageState(this.center, this.bloc);

  final LatLng center;
  final GeometryBloc bloc;

  int _currentMap = 0;
  MapController mapController;
  List<LayerOptions> _baseMaps;
  LayerOptions mbTileOptions;
  Set<String> inProgress = HashSet<String>();
  ValueNotifier progress = ValueNotifier<double>(0.0);

//  File _selectedFile;

  @override
  void initState() {
    super.initState();
//    var assetPath = "/data/user/0/org.discoos.flutterapp/app_flutter";
    _baseMaps = <LayerOptions>[
      TileLayerOptions(
        offlineMode: true,
        urlTemplate: "assets/topo4/oslo/{z}/{x}/{y}.png",
      ),
      TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c']),
    ];
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    List<LayerOptions> layers = <LayerOptions>[_baseMaps[_currentMap]];

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        drawer: buildDrawer(context, MapOfflinePage.route), // Drawer
        body: Stack(
          children: <Widget>[
            FlutterMap(
              options: MapOptions(
                center: center,
                zoom: 13.0,
                maxZoom: 18.0,
                minZoom: 1.0,
              ),
              layers: layers,
              mapController: mapController,
            ),
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                return Container(
                  child: LinearProgressIndicator(
                    value: progress.value,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                  height: inProgress.isNotEmpty ? 5.0 : 0.0,
                );
              },
            ),
          ],
        ),
        floatingActionButton: FabToolbar(
          buttons: _createDirectActions(),
          toggled: _createToggledActions(),
        ));
  }

  List<Widget> _createToggledActions() {
    List<Widget> buttons = <Widget>[];

    buttons.addAll([
      Container(
        child: FloatingActionButton(
          onPressed: () => _moveTo(center),
          tooltip: 'Home',
          mini: true,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.home,
            color: Colors.black,
          ),
        ),
      ),
      Container(
        child: FloatingActionButton(
          onPressed: _addFromStorage,
          tooltip: 'Add tiles from storage',
          mini: true,
          backgroundColor:
              inProgress.contains("storage") ? Colors.redAccent : Colors.white,
          child: Icon(
            Icons.sd_storage,
            color: inProgress.contains("storage") ? Colors.white : Colors.black,
          ),
        ),
      ),
      Container(
        child: FloatingActionButton(
          onPressed: _addFromUrl,
          tooltip: 'Add tiles from url',
          mini: true,
          backgroundColor:
              inProgress.contains("download") ? Colors.redAccent : Colors.white,
          child: Icon(
            Icons.file_download,
            color:
                inProgress.contains("download") ? Colors.white : Colors.black,
          ),
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
              _currentMap = (_currentMap + 1) % _baseMaps.length;
            });
          },
          tooltip: 'Layers',
          mini: true,
          backgroundColor: Colors.white,
          child: Icon(Icons.layers, color: Colors.black),
        ),
      ),
    ]);

    return buttons;
  }

  void _moveTo(LatLng center) {
    mapController.move(center, 13.0);
  }

  void _startProgress(String task) {
    inProgress.add(task);
    progress.value = null;
  }

  void _stopProgress() {
    setState(() {
      inProgress.clear();
      progress.value = null;
    });
  }

  void _addFromUrl() {
    setState(() {
      _startProgress("download");
      _doAddFromUrl(MapOfflinePage.mbtiles, "oslo.mbtiles");
    });
  }

  void _addFromStorage() {
    setState(() {
      _startProgress("storage");
      _doAddFromStorage();
    });
  }

  void _doAddFromStorage() async {
    String filePath = await _doSelectFilePath();
    if (filePath?.isNotEmpty != null) {
      File file = File(filePath);

      //Get directory of the application. This way works best for iOS.
      //The main point here is that the origin of the file is not relevant,
      //as long as you have access to the file.
      //Add path_provider dependency in example/pubspec.yaml to use the next function
      Directory appDirectory = await getApplicationDocumentsDirectory();
      var assetPath = "${appDirectory.path}/maps";
      print(file.path);
      print(assetPath);

      Directory(assetPath).create(recursive: true).then((Directory directory) {
        _doExtractToFile(file, assetPath);
      });
    } else {
      _stopProgress();
    }
  }

  Future<String> _doSelectFilePath() async {
    try {
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ['mbtiles'],
        allowedUtiTypes: ['mbtiles'],
      );

      String filePath =
          await FlutterDocumentPicker.openDocument(params: params);
      if (filePath != '') {
        print("Selected file: $filePath");
        return filePath;
      }
    } on PlatformException catch (e) {
      print("Error while picking the file: ${e.toString()}");
    }
    return null;
  }

  void _doAddFromUrl(String url, String filename) async {
    http.Client client = http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);

    //Get directory of the application. This way works best for iOS.
    //The main point here is that the origin of the file is not relevant,
    //as long as you have access to the file.
    //Add path_provider dependency in example/pubspec.yaml to use the next function
    Directory appDirectory = await getApplicationDocumentsDirectory();
    var assetPath = "${appDirectory.path}";
    print(file.path);
    print(assetPath);

    Directory(assetPath).create(recursive: true).then((Directory directory) {
      _doExtractToFile(file, assetPath);
    });
  }

  void _doExtractToFile(File file, String extractTo) async {
    StreamSubscription<dynamic> subscription;

    try {
      subscription = MBTilesExtractor.onProgress().listen((dynamic event) {
        var percent = event['progress'] / event['total'];
        if (percent == 1.0) {
          _stopProgress();
        } else {
          progress.value = percent;
        }
        print("$event");
      });

      ExtractResult extractResult = await MBTilesExtractor.extractMBTilesFile(
        ExtractRequest(
          file.path,
          //This is the name of the file i was testing.
          desiredPath: extractTo,
          //Example of final folder
          requestPermissions: true,
          //Vital in android
          removeAfterExtract: true,
          //Deletes the *.mbtiles file after the extraction is completed
          stopOnError: true,
          //Stops is one tile could not be extracted
          returnReference: true,
          //Returns the list of tiles once the extraction is completed
          onlyReference: false,
          // If true the reference of tiles is returned but the extraction is not performed
          schema: Schema.XYZ,
          //Flip y-axis to commonly used xyz (slippy map) tiling format.
        ),
      );

      if (extractResult.isSuccessful()) {
        setState(() {
          var folder = extractResult.data;
          _baseMaps.add(TileLayerOptions(
            offlineMode: true,
            fromAssets: false,
            urlTemplate: "$folder/{z}/{x}/{y}.png",
          ));
          _currentMap = _baseMaps.length - 1;
        });
        //Do something
      }
    } catch (ex, st) {
      print(ex);
      print(st);
    }

    subscription?.cancel();
  }
}
