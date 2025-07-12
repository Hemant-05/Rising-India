import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Check and request location permissions
  static Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  static Future<String> getReadableAddress(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // Filter out numeric name or subThoroughfare if needed
        String city = placemark.locality ?? "";
        String state = placemark.administrativeArea ?? "";
        String postalCode = placemark.postalCode ?? "";
        String country = placemark.country ?? "";

        return "$city, $state, $postalCode, $country";
      } else {
        return "Location not found";
      }
    } catch (e) {
      print("Error getting address: $e");
      return "Unable to fetch address";
    }
  }

  // Get current position
  static Future<Position?> getCurrentPosition() async {
    if (!await _checkPermissions()) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  // Get human-readable address from coordinates
  static Future<String?> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return null;
  }
}