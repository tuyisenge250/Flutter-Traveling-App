class Destination {
  final String id;
  final String name;
  final String country;
  final String category;
  final String description;
  final String imagePath;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final List<String> highlights;
  final String duration;
  final bool isFavorite;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.highlights,
    required this.duration,
    this.isFavorite = false,
  });
}
