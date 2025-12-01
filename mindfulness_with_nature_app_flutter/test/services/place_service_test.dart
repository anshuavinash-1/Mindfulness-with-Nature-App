// Unit tests for PlacesService.
// 
// PlacesService manages favorite nature locations using local storage (SharedPreferences).
// These tests verify:
// - Adding, updating, and deleting favorite places
// - Geolocation calculations using the Haversine formula
// - Finding places within a radius of a given location
// - Data persistence through SharedPreferences
// - Immutability of exposed data
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfulness_with_nature_app_flutter/services/place_service.dart';
import 'package:mindfulness_with_nature_app_flutter/models/favorite_place.dart';

void main() {
  // Tests for PlacesService: favorite location management with geolocation
  group('PlacesService', () {
    late PlacesService placesService;

    setUp(() async {
      // Create a fresh PlacesService instance before each test
      // Mock SharedPreferences with empty state to ensure test isolation
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      placesService = PlacesService(prefs);
      await Future.delayed(Duration.zero);
    });

    // Tests for service initialization with empty state
    group('Initialization', () {
      // Test that new service instance starts with no saved places
      test('should start with empty places list', () {
        expect(placesService.places, isEmpty);
      });
    });

    // Tests for adding favorite places with GPS coordinates
    group('addPlace', () {
      // Test adding a single favorite place with coordinates and description
      test('should add a new place', () async {
        final place = FavoritePlace(
          id: 'test-1',
          name: 'Mountain View',
          latitude: 45.0,
          longitude: -123.0,
          description: 'Great hiking',
          addedAt: DateTime.now(),
          userId: 'test-user',
        );

        await placesService.addPlace(place);

        // Verify place was added and name is correct
        expect(placesService.places.length, equals(1));
        expect(placesService.places.first.name, equals('Mountain View'));
      });

      // Test adding multiple favorite places (beach, lake, mountain, etc.)
      test('should add multiple places', () async {
        final place1 = FavoritePlace(
          id: 'test-1',
          name: 'Beach',
          latitude: 45.0,
          longitude: -124.0,
          description: 'Sandy beach',
          addedAt: DateTime.now(),
          userId: 'test-user',
        );

        final place2 = FavoritePlace(
          id: 'test-2',
          name: 'Lake',
          latitude: 46.0,
          longitude: -123.0,
          description: 'Calm lake',
          addedAt: DateTime.now(),
          userId: 'test-user',
        );

        await placesService.addPlace(place1);
        await placesService.addPlace(place2);

        expect(placesService.places.length, equals(2));
      });
    });

    // Tests for removing places from favorites list
    group('deletePlace', () {
      // Test removing a favorite place by its unique ID
      test('should remove an existing place by id', () async {
        final place = FavoritePlace(
          id: 'test-1',
          name: 'Park',
          latitude: 45.0,
          longitude: -122.0,
          description: 'City park',
          addedAt: DateTime.now(),
          userId: 'test-user',
        );

        await placesService.addPlace(place);
        expect(placesService.places.length, equals(1));

        await placesService.deletePlace('test-1');
        // Place should be removed from storage
        expect(placesService.places, isEmpty);
      });

      // Test that deleting a non-existent place doesn't throw an error
      test('should not throw when deleting non-existent place', () async {
        await placesService.deletePlace('non-existent-id');
        expect(placesService.places, isEmpty);
      });
    });

    // Tests for modifying existing place information
    group('updatePlace', () {
      // Test modifying name, coordinates, or description of saved place
      test('should update an existing place', () async {
        final place = FavoritePlace(
          id: 'test-1',
          name: 'Park',
          latitude: 45.0,
          longitude: -122.0,
          description: 'Old description',
          addedAt: DateTime.now(),
          userId: 'test-user',
        );

        await placesService.addPlace(place);

        final updatedPlace = FavoritePlace(
          id: 'test-1',
          name: 'Updated Park',
          latitude: 45.1,
          longitude: -122.1,
          description: 'New description',
          addedAt: place.addedAt,
          userId: 'test-user',
        );

        await placesService.updatePlace(updatedPlace);

        // Verify changes were persisted
        expect(placesService.places.first.name, equals('Updated Park'));
        expect(placesService.places.first.description, equals('New description'));
      });

      // Test that updating a non-existent ID doesn't create a new place
      test('should not add new place if id does not exist', () async {
        final place = FavoritePlace(
          id: 'non-existent',
          name: 'New Place',
          latitude: 45.0,
          longitude: -122.0,
          description: 'Test',
          addedAt: DateTime.now(),
          userId: 'test-user',
        );

        await placesService.updatePlace(place);
        expect(placesService.places, isEmpty);
      });
    });

    // Tests for finding places within a radius using Haversine distance formula
    group('getPlacesNearLocation', () {
      setUp(() async {
        // Add two places: one near Portland, one near Seattle (234km apart)
        // Add places at different distances from Portland (45.5, -122.7)
        await placesService.addPlace(FavoritePlace(
          id: 'nearby',
          name: 'Nearby Place',
          latitude: 45.51, // Very close (~1.5 km from Portland)
          longitude: -122.71,
          description: 'Close to Portland',
          addedAt: DateTime.now(),
          userId: 'test-user',
        ));

        await placesService.addPlace(FavoritePlace(
          id: 'far',
          name: 'Far Place',
          latitude: 47.6, // Seattle area (~234 km from Portland)
          longitude: -122.3,
          description: 'Far from Portland',
          addedAt: DateTime.now(),
          userId: 'test-user',
        ));
      });

      // Test finding places within 50km radius of Portland
      test('should return places within radius', () {
        // Query from Portland with 50km radius
        final nearby = placesService.getPlacesNearLocation(
          45.5,    // Portland latitude
          -122.7,  // Portland longitude
          50.0,    // 50 km radius
        );

        // Should only find the nearby place (~1.5km), not Seattle (~234km)
        expect(nearby.length, equals(1));
        expect(nearby.first.name, equals('Nearby Place'));
      });

      // Test that large radius (500km) captures all places including distant ones
      test('should return all places with large radius', () {
        // Large radius should capture both Portland and Seattle locations
        final nearby = placesService.getPlacesNearLocation(
          45.5,
          -122.7,
          500.0, // 500 km radius
        );

        // Should find both places within 500km
        expect(nearby.length, equals(2));
      });

      // Test that very small radius (100m) finds no places
      test('should return empty list with very small radius', () {
        final nearby = placesService.getPlacesNearLocation(
          45.5,
          -122.7,
          0.1, // 100 m radius
        );

        expect(nearby, isEmpty);
      });
    });

    // Tests for data immutability of the public places list
    group('places getter', () {
      // Test that returned places list cannot be modified externally
      test('should return unmodifiable list', () {
        final places = placesService.places;
        expect(
          () => places.add(
            FavoritePlace(
              id: 'test',
              name: 'Test',
              latitude: 45.0,
              longitude: -122.0,
              description: 'Test',
              addedAt: DateTime.now(),
              userId: 'test-user',
            ),
          ),
          throwsUnsupportedError,
        );
      });
    });
  });
}
