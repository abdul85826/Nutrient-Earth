import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_service.dart';
import 'aqi_service.dart';
import '../models/app_models.dart';

class EnvironmentState {
  final WeatherData weather;
  final AqiData aqi;
  final String city;
  final DateTime lastUpdated;
  final bool isLoading;

  EnvironmentState({
    required this.weather,
    required this.aqi,
    required this.city,
    required this.lastUpdated,
    this.isLoading = false,
  });

  EnvironmentData get data => EnvironmentData(
    city: city,
    temp: weather.temp.toDouble(),
    humidity: weather.humidity.toDouble(),
    aqi: aqi.aqi,
    uvi: weather.uvi.toDouble(),
    description: weather.description,
  );

  factory EnvironmentState.initial() {
    return EnvironmentState(
      weather: WeatherData.placeholder(),
      aqi: AqiData.placeholder(),
      city: 'Detecting Location...',
      lastUpdated: DateTime.now(),
      isLoading: true,
    );
  }

  EnvironmentState copyWith({
    WeatherData? weather,
    AqiData? aqi,
    String? city,
    DateTime? lastUpdated,
    bool? isLoading,
  }) {
    return EnvironmentState(
      weather: weather ?? this.weather,
      aqi: aqi ?? this.aqi,
      city: city ?? this.city,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EnvironmentNotifier extends StateNotifier<EnvironmentState> {
  EnvironmentNotifier() : super(EnvironmentState.initial()) {
    refresh();
  }

  EnvironmentData get currentData => state.data;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    
    // Try loading cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedWeatherStr = prefs.getString('cached_weather');
      final cachedAqiStr = prefs.getString('cached_aqi');
      if (cachedWeatherStr != null && cachedAqiStr != null) {
        final weather = WeatherData.fromJson(jsonDecode(cachedWeatherStr));
        final aqi = AqiData.fromJson(jsonDecode(cachedAqiStr));
        state = state.copyWith(
          weather: weather,
          aqi: aqi,
          city: 'Cached Location',
          isLoading: false,
        );
      }
    } catch (e) {
      print('⚠️ Failed to load environment cache: $e');
    }

    try {
      // 1. Get Location
      final position = await _determinePosition();

      // 2. Fetch APIs in parallel
      final weatherData = await WeatherService.fetchWeatherRaw(position.latitude, position.longitude);
      final aqiData = await AqiService.fetchAqiRaw(position.latitude, position.longitude);

      if (weatherData != null && aqiData != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_weather', jsonEncode(weatherData));
        await prefs.setString('cached_aqi', jsonEncode(aqiData));

        state = EnvironmentState(
          weather: WeatherData.fromJson(weatherData),
          aqi: AqiData.fromJson(aqiData),
          city: 'Current Location',
          lastUpdated: DateTime.now(),
          isLoading: false,
        );
        print('🌍 Environment Updated from Live API');
      } else {
        // Fallback to state if already loaded from cache, else placeholder
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('🔥 Environment Refresh Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Do not request permissions on boot to prevent UI hang and popup spam
      throw Exception('Location permissions are denied (not requesting on startup)');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Try last known position first
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      return lastKnown;
    }

    // Otherwise, call getCurrentPosition with low accuracy and a short timeout
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 4),
      ),
    );
  }
}

final environmentProvider =
    StateNotifierProvider<EnvironmentNotifier, EnvironmentState>((ref) {
      return EnvironmentNotifier();
    });
