import 'package:flutter/material.dart';

/// Current conditions for a location. In the scaffold this comes from a mock
/// repository; the shape is already what a real provider (OpenWeather / Open-Meteo)
/// will return, so swapping it later touches one file only.
class Weather {
  const Weather({
    required this.city,
    required this.label,
    required this.temp,
    required this.feels,
    required this.humidity,
    required this.wind,
    required this.rainChance,
    required this.sunrise,
    required this.sunset,
  });

  final String city;

  /// 'Clear', 'Partly cloudy', 'Light rain', …
  final String label;

  final int temp;
  final int feels;

  /// Percent, 0–100.
  final int humidity;
  final int rainChance;

  /// km/h.
  final int wind;

  final String sunrise;
  final String sunset;

  bool get isWet => rainChance >= 40;
  bool get isHot => temp >= 29;
  bool get isCool => temp < 18;

  String get umbrellaNote =>
      isWet ? 'Rain later — keep the umbrella by the door.' : 'No rain expected today.';

  /// Short line the outfit card shows under the temperature.
  String get summary => '$temp° · $label · $humidity% humidity · $wind km/h';

  IconData get icon {
    if (isWet) return Icons.grain;
    switch (label) {
      case 'Clear':
        return Icons.wb_sunny_outlined;
      case 'Partly cloudy':
        return Icons.wb_cloudy_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }
}
