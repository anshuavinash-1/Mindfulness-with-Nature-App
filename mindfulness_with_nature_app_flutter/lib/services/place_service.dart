import 'dart:convert';
import 'dart:math' show sin, cos, sqrt, asin, pi;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_place.dart';

// The PlacesService manages the CRUD operations and distance calculations
// for the user's favorite nature places. It uses SharedPreferences for persistence.
class PlacesService with ChangeNotifier {
  static const String _storageKey = 'favorite_places';
  final SharedPreferences _prefs;
  List<FavoritePlace> _places = [];

  // Constructor requires SharedPreferences instance and immediately loads data
  PlacesService(this._prefs) {
    _loadPlaces();
  }

  // Getter for the list of places, returns an unmodifiable list for safety
  List<FavoritePlace> get places => List.unmodifiable(_places);

  // Load places from storage
  Future<void> _loadPlaces() async {
    final String? placesJson = _prefs.getString(_storageKey);
    if (placesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(placesJson);
        _places = decoded.map((item) => FavoritePlace.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        // Handle potential parsing errors from corrupted data
        if (kDebugMode) {
          print('Error loading places from storage: $e');
        }
        _places = []; // Clear data if loading fails
      }
    }
  }

  // Save places to storage (JSON encoding)
  Future<void> _savePlaces() async {
    final String encoded = jsonEncode(_places.map((p) => p.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  // Add a new favorite place
  Future<void> addPlace(FavoritePlace place) async {
    _places.add(place);
    await _savePlaces();
    notifyListeners();
  }

  // Update an existing place
  Future<void> updatePlace(FavoritePlace updated) async {
    final index = _places.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _places[index] = updated;
      await _savePlaces();
      notifyListeners();
    }
  }

  // Delete a place by its ID
  Future<void> deletePlace(String placeId) async {
    _places.removeWhere((p) => p.id == placeId);
    await _savePlaces();
    notifyListeners();
  }

  // Get places near a location (geospatial query)
  List<FavoritePlace> getPlacesNearLocation(
      double lat, double lng, double radiusKm) {
    return _places.where((place) {
      final distance =
          _calculateDistance(lat, lng, place.latitude, place.longitude);
      return distance <= radiusKm;
    }).toList();
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  // Helper to convert degrees to radians
  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
