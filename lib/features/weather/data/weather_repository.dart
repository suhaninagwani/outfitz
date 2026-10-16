import 'dart:math';

import '../domain/weather.dart';

/// Stand-in for a real forecast call.
///
/// Shape matches what we'll get from Open-Meteo (free, no API key — the
/// cost-efficient choice for this project), so the swap is one file.
class WeatherRepository {
  const WeatherRepository({this.city = 'Greater Noida'});

  final String city;

  Weather today() {
    final now = DateTime.now();
    // A small seasonal wobble so the app doesn't look frozen.
    final jitter = (now.day % 5) - 2;
    final base = switch (now.month) {
      >= 3 && <= 5 => 30, // summer
      >= 6 && <= 9 => 26, // monsoon
      >= 10 && <= 11 => 24, // post-monsoon
      _ => 15, // winter
    };
    final temp = base + jitter;
    final wet = now.month >= 6 && now.month <= 9;

    return Weather(
      city: city,
      label: wet ? 'Light rain' : (jitter.isEven ? 'Clear' : 'Partly cloudy'),
      temp: temp,
      feels: temp + 3,
      humidity: wet ? 78 : 40 + jitter.abs() * 3,
      wind: 9 + Random(now.day).nextInt(8),
      rainChance: wet ? 65 : 10,
      sunrise: '06:12',
      sunset: '18:34',
    );
  }

  /// Five-day outlook that backfills the planner.
  List<Weather> week() => List.generate(5, (i) {
        final t = today();
        final drift = ((i * 7) % 5) - 2;
        return Weather(
          city: t.city,
          label: i == 3 ? 'Light rain' : (i.isEven ? 'Clear' : 'Partly cloudy'),
          temp: t.temp + drift,
          feels: t.feels + drift,
          humidity: t.humidity + ((i * 3) % 7),
          wind: t.wind + (i % 3),
          rainChance: i == 3 ? 70 : (i == 1 ? 35 : 15),
          sunrise: t.sunrise,
          sunset: t.sunset,
        );
      });
}
