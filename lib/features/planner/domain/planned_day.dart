import '../../outfits/domain/outfit.dart';
import '../../weather/domain/weather.dart';

/// One row of the week planner.
class PlannedDay {
  const PlannedDay({
    required this.date,
    required this.weather,
    this.outfit,
  });

  final DateTime date;
  final Weather weather;

  /// Null on a rest day, or when the wardrobe can't cover that day.
  final Outfit? outfit;

  String get weekday => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      [date.weekday - 1];

  bool get isToday {
    final n = DateTime.now();
    return n.year == date.year && n.month == date.month && n.day == date.day;
  }

  PlannedDay copyWith({Outfit? outfit}) =>
      PlannedDay(date: date, weather: weather, outfit: outfit ?? this.outfit);
}
