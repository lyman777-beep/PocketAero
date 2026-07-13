import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class OfflineMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final double? heading;

  const OfflineMap({
    super.key,
    this.latitude,
    this.longitude,
    this.heading,
  });

  @override
  State<OfflineMap> createState() => _OfflineMapState();
}

class _OfflineMapState extends State<OfflineMap> {
  final mapController = MapController();
  bool _followPosition = true;

  @override
  Widget build(BuildContext context) {
    final hasPosition = widget.latitude != null && widget.longitude != null;
    final center = hasPosition
        ? LatLng(widget.latitude!, widget.longitude!)
        : const LatLng(39.9042, 116.4074);

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12.0,
            onTap: (_, _) {
              setState(() => _followPosition = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.pocketacro.pocket_aero',
            ),
            if (hasPosition)
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 24,
                    height: 24,
                    child: Transform.rotate(
                      angle: (widget.heading ?? 0) * 3.14159 / 180,
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xFF00D4FF),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (hasPosition && _followPosition)
          Positioned(
            right: 12,
            bottom: 12,
            child: FloatingActionButton.small(
              heroTag: 'follow',
              backgroundColor: const Color(0xFF00D4FF),
              onPressed: () {
                mapController.move(center, mapController.camera.zoom);
              },
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        Positioned(
          left: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'OPENSTREETMAP',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(OfflineMap old) {
    super.didUpdateWidget(old);
    if (_followPosition &&
        widget.latitude != null &&
        widget.longitude != null) {
      mapController.move(
        LatLng(widget.latitude!, widget.longitude!),
        mapController.camera.zoom,
      );
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
