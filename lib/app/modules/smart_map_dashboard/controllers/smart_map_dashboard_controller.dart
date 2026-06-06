import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/smart_map_dashboard_model.dart';

class SmartMapDashboardController extends GetxController {
  final isLoading = true.obs;
  final permissionGranted = false.obs;
  final panelExpanded = true.obs;
  final currentAddress = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final selectedMapTheme = 'standard'.obs;
  final currentMapType = MapType.normal.obs;
  final locationModel = Rxn<SmartMapDashboardModel>();
  final isAddressLoading = false.obs;
  final currentZoom = 15.0.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final savedLocations = <SavedLocation>[].obs;
  final selectedTabIndex = 0.obs;

  GoogleMapController? _mapController;
  final mapKeyCounter = 0.obs;
  final isDarkMode = false.obs;

  static const String darkMapStyle = r'''
  [
    {"elementType": "geometry", "stylers": [{"color": "#1a1a2e"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#8a8a9a"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a1a2e"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#2a2a3e"}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#1e1e30"}]},
    {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#252538"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#1e3020"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#2a2a40"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3a3a55"}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#1a1a2e"}]},
    {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#2a2a40"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0e1a2e"}]}
  ]
  ''';


  final currentPosition = Rxn<Position>();
  Stream<Position>? _positionStream;

  static const CameraPosition _defaultCamera = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14.0,
  );

  CameraPosition get initialCamera => _defaultCamera;

  Marker get currentMarker {
    final hasLocation = latitude.value != 0.0 || longitude.value != 0.0;
    if (hasLocation) {
      return Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(latitude.value, longitude.value),
        infoWindow: InfoWindow(title: 'You', snippet: currentAddress.value),
      );
    }
    return Marker(
      markerId: const MarkerId('default'),
      position: _defaultCamera.target,
      infoWindow: const InfoWindow(title: 'Default'),
    );
  }

  Set<Marker> get allMarkers {
    final markers = <Marker>{currentMarker};
    for (int i = 0; i < savedLocations.length; i++) {
      final loc = savedLocations[i];
      markers.add(Marker(
        markerId: MarkerId('saved_$i'),
        position: LatLng(loc.latitude, loc.longitude),
        infoWindow: InfoWindow(title: loc.name, snippet: loc.address),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ));
    }
    return markers;
  }

  @override
  void onInit() {
    super.onInit();
    requestPermission();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  Future<void> requestPermission() async {
    isLoading.value = true;
    try {
      if (kIsWeb) {
        permissionGranted.value = true;
        isLoading.value = false;
        await Future.delayed(const Duration(milliseconds: 600));
        mapKeyCounter.value++;
        return;
      }
      permissionGranted.value = true;
      await _getCurrentLocation();
      _startLocationStream();
    } catch (e) {
      permissionGranted.value = false;
      isLoading.value = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentPosition.value = position;
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      currentZoom.value = 15.0;
      await _updateAddress(position);
      _animateCamera(position.latitude, position.longitude);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  void _startLocationStream() {
    const locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
    _positionStream?.listen((Position position) {
      currentPosition.value = position;
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      _updateAddress(position);
    });
  }

  Future<void> _updateAddress(Position position) async {
    isAddressLoading.value = true;
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _applyAddressData(place);
        isAddressLoading.value = false;
        return;
      }
    } catch (_) {}

    try {
      await _fetchAddressViaHttp(position.latitude, position.longitude);
    } catch (_) {
      currentAddress.value = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      locationModel.value = SmartMapDashboardModel(
        latitude: position.latitude,
        longitude: position.longitude,
        address: currentAddress.value,
        updatedAt: DateTime.now(),
      );
    }
    isAddressLoading.value = false;
  }

  void _applyAddressData(Placemark place) {
    final addressParts = [
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((e) => e != null && e.isNotEmpty).toList();
    currentAddress.value = addressParts.join(', ');
    locationModel.value = SmartMapDashboardModel(
      latitude: latitude.value,
      longitude: longitude.value,
      address: currentAddress.value,
      city: place.locality,
      state: place.administrativeArea,
      country: place.country,
      postalCode: place.postalCode,
      subLocality: place.subLocality,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _fetchAddressViaHttp(double lat, double lng) async {
    try {
      final apiKey = MahekConstant.googleMapKey;

      if (apiKey.isEmpty) {
        currentAddress.value = 'Google Map API key missing';
        return;
      }

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        currentAddress.value = 'Failed to load address';
        return;
      }

      final data = json.decode(response.body);


      final status = data['status'];

      if (status != 'OK') {
        currentAddress.value = 'Address unavailable ($status)';
        return;
      }

      final results = data['results'] as List?;

      if (results == null || results.isEmpty) {
        currentAddress.value = 'No address found';
        return;
      }

      final result = results.first;

      currentAddress.value =
          result['formatted_address'] ?? 'Unknown address';

      String? city;
      String? state;
      String? country;
      String? postalCode;
      String? subLocality;

      final addressComponents =
          result['address_components'] as List? ?? [];

      for (var component in addressComponents) {
        final types = List<String>.from(component['types'] ?? []);

        if (types.contains('locality')) {
          city = component['long_name'];
        }

        if (types.contains('administrative_area_level_1')) {
          state = component['long_name'];
        }

        if (types.contains('country')) {
          country = component['long_name'];
        }

        if (types.contains('postal_code')) {
          postalCode = component['long_name'];
        }

        if (types.contains('sublocality') ||
            types.contains('sublocality_level_1')) {
          subLocality = component['long_name'];
        }
      }

      locationModel.value = SmartMapDashboardModel(
        latitude: lat,
        longitude: lng,
        address: currentAddress.value,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        subLocality: subLocality,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print("ADDRESS ERROR => $e");

      currentAddress.value =
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
  }

  void _animateCamera(double lat, double lng) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), currentZoom.value));
  }

  void onMapCreated(GoogleMapController controller, bool isDark) {
    _mapController = controller;
    isDarkMode.value = isDark;
    applyMapStyle(isDark);
    if (latitude.value != 0.0 && longitude.value != 0.0) {
      _animateCamera(latitude.value, longitude.value);
    }
  }

  void applyMapStyle(bool isDark) {
    isDarkMode.value = isDark;
    if (_mapController == null) return;
    _mapController!.setMapStyle(isDark ? darkMapStyle : null);
  }

  void togglePanel() => panelExpanded.value = !panelExpanded.value;

  void changeMapType(MapType type) {
    currentMapType.value = type;
    switch (type) {
      case MapType.normal:
        selectedMapTheme.value = 'standard';
        break;
      case MapType.satellite:
        selectedMapTheme.value = 'satellite';
        break;
      case MapType.terrain:
        selectedMapTheme.value = 'terrain';
        break;
      case MapType.hybrid:
        selectedMapTheme.value = 'hybrid';
        break;
      default:
        selectedMapTheme.value = 'standard';
    }
  }

  Future<void> refreshLocation() async {
    isLoading.value = true;
    await _getCurrentLocation();
    ShowToastDialog.showSuccess('Location refreshed');
  }

  void recenterMap() {
    if (latitude.value != 0.0 && longitude.value != 0.0) {
      _animateCamera(latitude.value, longitude.value);
    }
  }

  void zoomIn() {
    currentZoom.value = (currentZoom.value + 1).clamp(0, 21);
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    currentZoom.value = (currentZoom.value - 1).clamp(0, 21);
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void openInGoogleMaps() {
    final url = 'https://www.google.com/maps/search/?api=1&query=${latitude.value},${longitude.value}';
    ShowToastDialog.showSuccess('Opening Google Maps');
  }

  void copyCoordinates() {
    final coords = '${latitude.value}, ${longitude.value}';
    Clipboard.setData(ClipboardData(text: coords));
    ShowToastDialog.showSuccess('Coordinates copied');
  }

  void shareLocation() {
    final text = 'My location: $currentAddress\nhttps://www.google.com/maps/search/?api=1&query=${latitude.value},${longitude.value}';
    Clipboard.setData(ClipboardData(text: text));
    ShowToastDialog.showSuccess('Location link copied to clipboard');
  }

  Future<void> searchPlace(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;

    try {
      final apiKey = MahekConstant.googleMapKey;

      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=$apiKey'
          '&components=country:in';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("SEARCH RESPONSE => $data");

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;

          searchResults.value = predictions.map((p) {
            return {
              'place_id': p['place_id'],
              'address': p['description'],
            };
          }).toList();
        } else {
          searchResults.clear();
        }
      }
    } catch (e) {
      print("SEARCH ERROR => $e");
      searchResults.clear();
    }

    isSearching.value = false;
  }


  void goToSearchResult(Map<String, dynamic> result) {
    final lat = result['lat'] as double;
    final lng = result['lng'] as double;
    latitude.value = lat;
    longitude.value = lng;
    currentAddress.value = result['address'] ?? '';
    _animateCamera(lat, lng);
    searchController.clear();
    searchResults.clear();
    panelExpanded.value = true;
  }

  void saveCurrentLocation({String? name}) {
    final loc = SavedLocation(
      name: name ?? 'Pin ${savedLocations.length + 1}',
      address: currentAddress.value,
      latitude: latitude.value,
      longitude: longitude.value,
      createdAt: DateTime.now(),
    );
    savedLocations.add(loc);
    ShowToastDialog.showSuccess('Location saved');
  }

  void removeSavedLocation(int index) {
    if (index >= 0 && index < savedLocations.length) {
      savedLocations.removeAt(index);
      ShowToastDialog.showSuccess('Location removed');
    }
  }

  void goToSavedLocation(SavedLocation loc) {
    latitude.value = loc.latitude;
    longitude.value = loc.longitude;
    currentAddress.value = loc.address;
    _animateCamera(loc.latitude, loc.longitude);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  @override
  void onClose() {
    searchController.dispose();
    _mapController?.dispose();
    super.onClose();
  }

  Future<void> goToPlaceDetails(String placeId) async {
    try {
      final apiKey = MahekConstant.googleMapKey;

      final url =
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['result'];

          final location = result['geometry']['location'];

          final lat = location['lat'];
          final lng = location['lng'];

          latitude.value = lat;
          longitude.value = lng;

          currentAddress.value =
              result['formatted_address'] ?? '';

          _animateCamera(lat, lng);

          searchController.clear();
          searchResults.clear();
        }
      }
    } catch (e) {
      print("PLACE DETAILS ERROR => $e");
    }
  }
}

class SavedLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  SavedLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });
}
