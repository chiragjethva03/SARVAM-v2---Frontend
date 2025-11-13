import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class LocationService {
  final loc.Location _location = loc.Location();

  // Get user-friendly location name like "Surat, Gujarat"
  Future<String> getCurrentLocationString() async {
    // 1. Check & request location service (shows popup like screenshot)
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception("Location service is still disabled");
      }
    }

    // 2. Request location permission
    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        throw Exception("Location permission denied");
      }
    }

    // 3. Get current coordinates
    loc.LocationData locationData = await _location.getLocation().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException("Fetching location took too long.");
      },
    );

    // 4. Convert coordinates to a readable address
    if (locationData.latitude != null && locationData.longitude != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.locality}, ${place.administrativeArea}";
      } else {
        throw Exception("Unable to get location name");
      }
    } else {
      throw Exception("Unable to fetch coordinates");
    }
  }

  // Get coordinates with timeout handling
  static Future<loc.LocationData?> getCurrentLocation() async {
    try {
      final loc.Location location = loc.Location();

      // Check & request service (shows popup like screenshot)
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          print("User denied to enable location service");
          return null;
        }
      }

      // Check permission
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          print("Location permission denied");
          return null;
        }
      }

      // Fetch coordinates
      loc.LocationData locationData = await location.getLocation().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException(
            "It seems your current location is in an area with limited network connectivity. Please try again in a few moments.",
          );
        },
      );

      print("Location fetched: ${locationData.latitude}, ${locationData.longitude}");
      return locationData;
    } catch (e) {
      print("Error fetching location: $e");
      return null;
    }
  }
}
