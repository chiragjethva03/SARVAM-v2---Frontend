import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LocationService {
  // Get user-friendly location name like "Surat, Gujarat"
  Future<String> getCurrentLocationString() async {
    // 1. Request location permission
    var status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      throw Exception("Location permission denied");
    }

    // 2. Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Open settings so user can enable location
      await Geolocator.openLocationSettings();
      // Re-check after user returns
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location service is still disabled");
      }
    }

    // 3. Get current coordinates
    Position position =
        await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException("Fetching location took too long.");
          },
        );

    // 4. Convert coordinates to a readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return "${place.locality}, ${place.administrativeArea}";
    } else {
      throw Exception("Unable to get location name");
    }
  }

  // Get coordinates with timeout handling
  static Future<Position?> getCurrentLocation() async {
    try {
      var status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        print("Location permission denied");
        return null;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Open settings to enable location
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print("Location service is still disabled");
          return null;
        }
      }

      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw TimeoutException(
                "It seems your current location is in an area with limited network connectivity. Please try again in a few moments.",
              );
            },
          );

      print("Location fetched: ${position.latitude}, ${position.longitude}");
      return position;  
    } catch (e) {
      print("Error fetching location: $e");
      return null;
    }
  }
}
