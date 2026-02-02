import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart';
import '../../widgets/app_logo.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapplsMapController? mapController;

  @override
  void initState() {
    super.initState();
    // API keys are configured in AndroidManifest.xml and Info.plist
  }

  void _onMapCreated(MapplsMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Areas'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AppLogo(size: 35),
          ),
        ],
      ),
      body: MapplsMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(28.6139, 77.2090), // Delhi coordinates
          zoom: 10.0,
        ),
      ),
    );
  }
}



