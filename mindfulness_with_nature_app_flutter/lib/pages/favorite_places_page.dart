import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Default to a central, nature-rich area (e.g., Golden Gate Park vicinity)
  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    // Use the listener to load places when the service changes (on initial load or update)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlacesService>(context, listen: false).addListener(_loadSavedPlaces);
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Remove listener when widget is disposed
    Provider.of<PlacesService>(context, listen: false).removeListener(_loadSavedPlaces);
    _nameController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _loadSavedPlaces();
  }

  // Reloads markers from the service data and updates the map
  void _loadSavedPlaces() {
    // Check if the widget is mounted before calling setState (can happen after async calls)
    if (!mounted) return;
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
            // Custom marker icon for better aesthetic
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            onTap: () => _showPlaceDetails(place),
          ),
        );
      }
    });
  }

  // Handles map taps to select a location for a new marker
  void _onMapTap(LatLng location) {
    // Clear any existing temporary "new_place" marker
    _markers.removeWhere((marker) => marker.markerId.value == 'new_place');

    setState(() {
      _selectedLocation = location;
      // Add a temporary marker (using a distinctive color, e.g., Green)
      _markers.add(
        Marker(
          markerId: const MarkerId('new_place'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });
    // Immediately prompt the user to name the spot
    _showAddPlaceDialog(location);
  }

  // Dialog to add a new place
  void _showAddPlaceDialog(LatLng location) {
    final theme = Theme.of(context);
    
    // Clear controllers before showing the dialog
    _nameController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // REQ-008: Use a themed background and text style
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add New Mindfulness Spot',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  // REQ-008: Themed border/focus style
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
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
                decoration: const InputDecoration(
                    labelText: 'Description (optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Remove the temporary marker if canceled
              _markers.removeWhere((marker) => marker.markerId.value == 'new_place');
              Navigator.pop(context);
            },
            // REQ-008: Use muted text color
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () => _savePlace(location),
            // REQ-008: Use primary theme button style
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
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

      // Ensure the user is authenticated before saving
      final userId = authService.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You must be logged in to save a place.'),
            backgroundColor: Colors.red.shade400,
          ),
        );
        Navigator.pop(context);
        return;
      }

      const uuid = Uuid();
      final newPlace = FavoritePlace(
        id: uuid.v4(),
        name: _nameController.text.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
        description: _descriptionController.text.trim(),
        addedAt: DateTime.now(),
        userId: userId,
      );

      placesService.addPlace(newPlace);
      // Remove the temporary marker after successful save
      _markers.removeWhere((marker) => marker.markerId.value == 'new_place');

      // Closes the dialog
      Navigator.pop(context);
      
      // Load saved places is automatically called via the listener, but an immediate
      // refresh can be triggered if needed, though usually the listener is sufficient.
      // _loadSavedPlaces(); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newPlace.name} saved!'),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        ),
      );
    }
  }

  // Shows details and delete option for an existing place
  void _showPlaceDetails(FavoritePlace place) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface, // REQ-008: Off-White Surface
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: GoogleFonts.lora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            if (place.description != null && place.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                place.description!,
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Added on: ${place.addedAt.day}/${place.addedAt.month}/${place.addedAt.year}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Delete logic
                    Provider.of<PlacesService>(context, listen: false)
                        .deletePlace(place.id);
                    Navigator.pop(context);
                    // _loadSavedPlaces() is called via listener
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${place.name} deleted'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  },
                  // REQ-008: Use Red for destructive action, but a muted shade
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    elevation: 1,
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // REQ-008: Use primary color for App Bar background (Sage Green)
        backgroundColor: theme.colorScheme.primary,
        // REQ-008: Use onPrimary color for icons/text (Off-White)
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
        title: Text(
          'My Mindfulness Spots',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _defaultLocation,
        // Listen to places changes to ensure markers are always up to date
        markers: Provider.of<PlacesService>(context).places.map((place) => 
           Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            onTap: () => _showPlaceDetails(place),
          )
        ).toSet(),
        onTap: _onMapTap,
      ),
      // REQ-008: Use themed Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // If no location is selected, explain how to select one
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tap a spot on the map to mark it as a new Favorite Place!'),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
            ),
          );
        },
        label: const Text('Tap to Add'),
        icon: const Icon(Icons.add_location_alt_outlined),
        backgroundColor: theme.colorScheme.secondary, // Secondary color (darker green/brown)
        foregroundColor: theme.colorScheme.onSecondary, // Off-White text
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}