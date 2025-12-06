import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AppHeader extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const AppHeader({super.key, this.onMenuTap});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String? _locationText;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationText = 'Location services disabled';
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _locationText = 'Permission denied';
          _loading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];
        if (p.street?.isNotEmpty == true) parts.add(p.street!);
        if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
        if (p.locality?.isNotEmpty == true) parts.add(p.locality!);
        if (p.subAdministrativeArea?.isNotEmpty == true) parts.add(p.subAdministrativeArea!);
        if (p.administrativeArea?.isNotEmpty == true) parts.add(p.administrativeArea!);
        if (p.postalCode?.isNotEmpty == true) parts.add(p.postalCode!);
        
        if (!mounted) return;
        setState(() {
          _locationText = parts.isNotEmpty ? parts.join(', ') : 'Location found';
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _locationText = 'Location unavailable';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationText = 'Unable to fetch location';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 22),
                    ],
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      _loading
                          ? 'Fetching location...'
                          : (_locationText ?? 'Fetching location...'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onMenuTap,
                child: Icon(Icons.menu, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
