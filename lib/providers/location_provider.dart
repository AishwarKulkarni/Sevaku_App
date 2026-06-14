import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

/// Provider for the LocationService instance
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// StateNotifier to hold and manage the user's current location (Position)
class CurrentLocationNotifier extends StateNotifier<AsyncValue<Position?>> {
  final LocationService _locationService;

  CurrentLocationNotifier(this._locationService) : super(const AsyncValue.data(null));

  /// Fetches the location and updates the state
  Future<void> fetchLocation() async {
    state = const AsyncValue.loading();
    try {
      final position = await _locationService.getCurrentLocation();
      state = AsyncValue.data(position);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the CurrentLocationNotifier
final currentLocationProvider = StateNotifierProvider<CurrentLocationNotifier, AsyncValue<Position?>>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return CurrentLocationNotifier(locationService);
});

/// Provider to directly get the human readable address based on current location
final currentAddressProvider = FutureProvider<String?>((ref) async {
  final locationState = ref.watch(currentLocationProvider);
  
  return locationState.when(
    data: (position) async {
      if (position == null) return null;
      final locationService = ref.watch(locationServiceProvider);
      return await locationService.getAddressFromCoordinates(position.latitude, position.longitude);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
