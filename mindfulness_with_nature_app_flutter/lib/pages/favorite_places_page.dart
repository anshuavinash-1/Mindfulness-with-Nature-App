import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/favorite_place.dart';
import '../services/places_service.dart';
import '../services/auth_service.dart';

class FavoritePlacesPage extends StatefulWidget {
  const FavoritePlacesPage({super.key});

  @override
  State<FavoritePlacesPage> createState() => _FavoritePlacesPageState();
}

class _FavoritePlacesPageState extends State<FavoritePlacesPage> {
  final _formKey = GlobalKey<FormState>();
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco
    zoom: 12,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _loadSavedPlaces();
  }

  void _loadSavedPlaces() {
    final placesService = Provider.of<PlacesService>(context, listen: false);
    setState(() {
      _markers.clear();
      for (var place in placesService.places) {
        _markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.description,
            ),
            onTap: () => _showPlaceDetails(place),
          ),
        );
      }
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.add(
        Marker(
          markerId: const MarkerId('new_place'),
          position: location,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });
    _showAddPlaceDialog(location);
  }

  void _showAddPlaceDialog(LatLng location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Mindfulness Spot'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Location Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _descriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _savePlace(location),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _savePlace(LatLng location) {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final placesService = Provider.of<PlacesService>(context, listen: false);

      final newPlace = FavoritePlace(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
        description: _descriptionController.text.trim(),
        addedAt: DateTime.now(),
        userId: authService.userEmail!,
      );

      placesService.addPlace(newPlace);
      _nameController.clear();
      _descriptionController.clear();

      Navigator.pop(context);
      _loadSavedPlaces();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location saved!')),
      );
    }
  }

  void _showPlaceDetails(FavoritePlace place) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(place.latitude, place.longitude),
        15,
      ),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (place.description != null && place.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(place.description!),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<PlacesService>(context, listen: false)
                        .deletePlace(place.id);
                    Navigator.pop(context);
                    _loadSavedPlaces();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location deleted')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _defaultLocation,
        markers: _markers,
        onTap: _onMapTap,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedLocation != null) {
            _showAddPlaceDialog(_selectedLocation!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tap a location on the map to add it'),
              ),
            );
          }
        },
        label: const Text('Add Place'),
        icon: const Icon(Icons.add_location),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}
