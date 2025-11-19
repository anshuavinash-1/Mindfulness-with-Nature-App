import 'dart:async';
import 'dart:convert';
import 'dart:math' show sin, cos, sqrt, asin, pi;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_place.dart';

class PlacesService with ChangeNotifier {
  static const String _storageKey = 'favorite_places';
  final SharedPreferences _prefs;
  List<FavoritePlace> _places = [];
  bool _isLoading = false;
  String? _error;

  PlacesService(this._prefs) {
    _initialize();
  }

  List<FavoritePlace> get places => List.unmodifiable(_places);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get placesCount => _places.length;

  // Initialize the service
  Future<void> _initialize() async {
    await _loadPlaces();
  }

  // Load places from storage with error handling
  Future<void> _loadPlaces() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final String? placesJson = _prefs.getString(_storageKey);
      
      if (placesJson != null && placesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(placesJson);
        _places = decoded.map((item) => FavoritePlace.fromJson(item)).toList();
        
        if (kDebugMode) {
          print('Loaded ${_places.length} favorite places from storage');
        }
      } else {
        _places = [];
        if (kDebugMode) {
          print('No favorite places found in storage');
        }
      }
    } catch (e) {
      _error = 'Failed to load favorite places: ${e.toString()}';
      _places = [];
      if (kDebugMode) {
        print('Error loading places: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save places to storage with error handling
  Future<bool> _savePlaces() async {
    try {
      final String encoded = jsonEncode(_places.map((p) => p.toJson()).toList());
      final success = await _prefs.setString(_storageKey, encoded);
      
      if (success && kDebugMode) {
        print('Saved ${_places.length} favorite places to storage');
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to save favorite places: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error saving places: $e');
      }
      return false;
    }
  }

  // Add a new favorite place with validation
  Future<bool> addPlace(FavoritePlace place) async {
    // Validate place data
    if (place.name.trim().isEmpty) {
      _error = 'Place name cannot be empty';
      notifyListeners();
      return false;
    }

    // Check for duplicates (same coordinates and name)
    final existingPlace = _places.firstWhere(
      (p) => p.latitude == place.latitude && 
             p.longitude == place.longitude && 
             p.name == place.name,
      orElse: () => FavoritePlace(
        id: '',
        name: '',
        latitude: 0,
        longitude: 0,
        addedAt: DateTime.now(),
        userId: '',
      ),
    );

    if (existingPlace.id.isNotEmpty) {
      _error = 'This place is already in your favorites';
      notifyListeners();
      return false;
    }

    _places.add(place);
    final success = await _savePlaces();
    
    if (success) {
      _error = null;
      notifyListeners();
      if (kDebugMode) {
        print('Added new favorite place: ${place.name}');
      }
    } else {
      // Rollback on failure
      _places.remove(place);
    }
    
    return success;
  }

  // Update an existing place
  Future<bool> updatePlace(FavoritePlace updated) async {
    if (updated.name.trim().isEmpty) {
      _error = 'Place name cannot be empty';
      notifyListeners();
      return false;
    }

    final index = _places.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      final originalPlace = _places[index];
      _places[index] = updated;
      
      final success = await _savePlaces();
      if (!success) {
        // Rollback on failure
        _places[index] = originalPlace;
        return false;
      }
      
      _error = null;
      notifyListeners();
      if (kDebugMode) {
        print('Updated favorite place: ${updated.name}');
      }
      return true;
    }
    
    _error = 'Place not found';
    notifyListeners();
    return false;
  }

  // Delete a place
  Future<bool> deletePlace(String placeId) async {
    final place = _places.firstWhere(
      (p) => p.id == placeId,
      orElse: () => FavoritePlace(
        id: '',
        name: '',
        latitude: 0,
        longitude: 0,
        addedAt: DateTime.now(),
        userId: '',
      ),
    );

    if (place.id.isEmpty) {
      _error = 'Place not found';
      notifyListeners();
      return false;
    }

    _places.removeWhere((p) => p.id == placeId);
    final success = await _savePlaces();
    
    if (!success) {
      // Rollback on failure
      _places.add(place);
      return false;
    }
    
    _error = null;
    notifyListeners();
    if (kDebugMode) {
      print('Deleted favorite place: ${place.name}');
    }
    return true;
  }

  // Get place by ID
  FavoritePlace? getPlaceById(String placeId) {
    try {
      return _places.firstWhere((p) => p.id == placeId);
    } catch (e) {
      return null;
    }
  }

  // Get places near a location with distance calculation
  List<FavoritePlace> getPlacesNearLocation(
    double lat, 
    double lng, 
    double radiusKm, {
    int maxResults = 10,
  }) {
    if (_places.isEmpty) return [];

    final nearbyPlaces = _places.map((place) {
      final distance = _calculateDistance(lat, lng, place.latitude, place.longitude);
      return _PlaceWithDistance(place: place, distance: distance);
    })
    .where((placeWithDistance) => placeWithDistance.distance <= radiusKm)
    .toList()
    ..sort((a, b) => a.distance.compareTo(b.distance));

    // Return only the closest places, limited by maxResults
    return nearbyPlaces
        .take(maxResults)
        .map((placeWithDistance) => placeWithDistance.place)
        .toList();
  }

  // Get places sorted by most recent
  List<FavoritePlace> getPlacesByRecent({int limit = 10}) {
    final sortedPlaces = List<FavoritePlace>.from(_places)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    
    return limit > 0 ? sortedPlaces.take(limit).toList() : sortedPlaces;
  }

  // Get places sorted by name
  List<FavoritePlace> getPlacesByName() {
    return List<FavoritePlace>.from(_places)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Search places by name or description
  List<FavoritePlace> searchPlaces(String query) {
    if (query.isEmpty) return _places;
    
    final lowercaseQuery = query.toLowerCase();
    return _places.where((place) {
      return place.name.toLowerCase().contains(lowercaseQuery) ||
             (place.description != null && 
              place.description!.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Clear all places (useful for testing or account reset)
  Future<bool> clearAllPlaces() async {
    final previousPlaces = List<FavoritePlace>.from(_places);
    _places.clear();
    
    final success = await _savePlaces();
    if (!success) {
      _places = previousPlaces;
      return false;
    }
    
    _error = null;
    notifyListeners();
    if (kDebugMode) {
      print('Cleared all favorite places');
    }
    return true;
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  // Clear any current error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data from storage
  Future<void> refresh() async {
    await _loadPlaces();
  }
}

// Helper class to store place with distance
class _PlaceWithDistance {
  final FavoritePlace place;
  final double distance;

  _PlaceWithDistance({
    required this.place,
    required this.distance,
  });
}