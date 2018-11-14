
import 'package:flutter/material.dart';
import 'package:flutter_map_demo/pages/map_groups_page.dart';
import 'package:flutter_map_demo/pages/map_offline_page.dart';
import 'package:flutter_map_demo/pages/map_overlays_page.dart';
import 'package:flutter_map_demo/pages/map_plugins_page.dart';

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: const Center(
            child: const Text("Flutter Map PoC"),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          title: const Text('Map with groups'),
          selected: currentRoute == MapGroupsPage.route,
          onTap: () {
            Navigator.pushReplacementNamed(context, MapGroupsPage.route);
          },
        ),
        ListTile(
          title: const Text('Map with overlays'),
          selected: currentRoute == MapOverlaysPage.route,
          onTap: () {
            Navigator.pushReplacementNamed(context, MapOverlaysPage.route);
          },
        ),
        ListTile(
          title: const Text('Map with plugins'),
          selected: currentRoute == MapPluginsPage.route,
          onTap: () {
          Navigator.pushReplacementNamed(context, MapPluginsPage.route);
        }),
        ListTile(
          title: const Text('Offline maps'),
          selected: currentRoute == MapOfflinePage.route,
          onTap: () {
          Navigator.pushReplacementNamed(context, MapOfflinePage.route);
        }),
      ],
    ),
  );
}