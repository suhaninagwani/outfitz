enum Category { top, bottom, layer, shoes }

class ClothingItem {
  final String name, emoji;
  final Category category;
  const ClothingItem(this.name, this.emoji, this.category);
}
