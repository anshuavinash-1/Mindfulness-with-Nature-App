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
  bool _isLoading = true;

  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _loadSavedPlaces();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () => _showPlaceDetails(place),
          ),
        );
      }
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      // Clear previous selection markers
      _markers.removeWhere((marker) => marker.markerId.value == 'new_place');
      _markers.add(
        Marker(
          markerId: const MarkerId('new_place'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'New Mindfulness Spot'),
        ),
      );
    });
    _showAddPlaceDialog(location);
  }

  void _showAddPlaceDialog(LatLng location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Mindfulness Spot',
          style: TextStyle(
            color: Color(0xFF2E5E3A), // Deep Forest
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tap on the map to select a peaceful location for your mindfulness practice',
                  style: TextStyle(
                    color: Color(0xFF708090), // Slate
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Location Name',
                    prefixIcon: Icon(Icons.place, color: Color(0xFF87A96B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF87A96B), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for this location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Why is this place peaceful?',
                    prefixIcon: Icon(Icons.description, color: Color(0xFF87A96B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF87A96B), width: 2),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _descriptionController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF708090)),
            ),
          ),
          ElevatedButton(
            onPressed: () => _savePlace(location),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF87A96B), // Sage Green
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Location'),
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
        SnackBar(
          content: Text('${newPlace.name} saved to your mindfulness spots!'),
          backgroundColor: Color(0xFF87A96B), // Sage Green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF87A96B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.place, color: Color(0xFF87A96B), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      place.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E5E3A), // Deep Forest
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (place.description != null && place.description!.isNotEmpty) ...[
                Text(
                  place.description!,
                  style: TextStyle(
                    color: Color(0xFF708090), // Slate
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Added ${_formatDate(place.addedAt)}',
                style: TextStyle(
                  color: Color(0xFFB8B8B8), // Stone
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF708090),
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _deletePlace(place);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDC2626), // Red
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePlace(FavoritePlace place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Location',
          style: TextStyle(color: Color(0xFF2E5E3A)),
        ),
        content: Text(
          'Are you sure you want to remove "${place.name}" from your mindfulness spots?',
          style: TextStyle(color: Color(0xFF708090)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF708090)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<PlacesService>(context, listen: false).deletePlace(place.id);
              Navigator.pop(context);
              _loadSavedPlaces();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${place.name}" removed'),
                  backgroundColor: Color(0xFF87A96B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${date.day}/${date.month}/${date.year}';
    }
  }

  void _centerOnUserLocation() {
    // For now, center on default location. In a real app, you'd use geolocation
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(_defaultLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4E9), // Pale Sand
      appBar: AppBar(
        title: Text(
          'Mindfulness Spots',
          style: TextStyle(
            color: Color(0xFF2E5E3A), // Deep Forest
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF87A96B), // Sage Green
        actions: [
          IconButton(
            onPressed: _centerOnUserLocation,
            icon: Icon(Icons.my_location),
            tooltip: 'Center on location',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF87A96B)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your mindfulness spots...',
                    style: TextStyle(
                      color: Color(0xFF708090), // Slate
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: _defaultLocation,
                  markers: _markers,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Tap anywhere on the map to add a peaceful mindfulness spot',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF708090), // Slate
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _centerOnUserLocation,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF87A96B),
            child: Icon(Icons.my_location),
            mini: true,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () {
              if (_selectedLocation != null) {
                _showAddPlaceDialog(_selectedLocation!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tap a location on the map first to add it'),
                    backgroundColor: Color(0xFF87A96B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            label: Text(
              'Add Spot',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            icon: Icon(Icons.add_location_alt),
            backgroundColor: Color(0xFF87A96B), // Sage Green
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}