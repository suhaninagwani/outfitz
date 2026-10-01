import '../features/weather/domain/weather.dart';
import '../features/wardrobe/domain/clothing_item.dart';

const todayWeather =
    Weather(temp: 31, feels: 34, humidity: 40, rain: 10, label: 'Clear', icon: '☀️');

const wardrobe = [
  ClothingItem('White tee', '👕', Category.top),
  ClothingItem('Blue jeans', '👖', Category.bottom),
  ClothingItem('Denim jacket', '🧥', Category.layer),
  ClothingItem('Sneakers', '👟', Category.shoes),
  ClothingItem('Floral top', '👚', Category.top),
  ClothingItem('Loafers', '👞', Category.shoes),
];

const week = [
  ('Thu', '1', '👕👖👟', '☀️ 31°'),
  ('Fri', '2', '👚👖👟', '⛅ 29°'),
  ('Sat', '3', '👗👡', '☀️ 32°'),
  ('Sun', '4', '👕🩳👟', '🌦 27°'),
  ('Mon', '5', '🧥👖👞', '🌧 24°'),
];
