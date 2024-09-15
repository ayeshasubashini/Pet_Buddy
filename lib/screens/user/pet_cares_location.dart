import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PetCaresLocation extends StatefulWidget {
  const PetCaresLocation({super.key});

  @override
  State<PetCaresLocation> createState() => _PetCaresLocationState();
}

class _PetCaresLocationState extends State<PetCaresLocation> {
  GoogleMapController? mapController;
  LatLng? _center;
  Position? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchPetCaresLocations();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permission denied, do nothing
        return;
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    });
  }

  _fetchPetCaresLocations() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('petCares').get();

      Set<Marker> markers = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final lat = double.tryParse(data['latitude'] ?? '');
        final lng = double.tryParse(data['longitude'] ?? '');

        if (lat != null && lng != null) {
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: data['name'] ?? 'No Name',
                snippet: data['address'] ?? 'No Address',
              ),
            ),
          );
        }
      }

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      // Handle error
      print('Error fetching pet care locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _center == null
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: double.infinity,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center!,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  rotateGesturesEnabled: true,
                  mapToolbarEnabled: true,
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                ),
              ),
      ),
    );
  }
}
