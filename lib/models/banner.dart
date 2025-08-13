// lib/models/banner.dart
class Banner {
  final String id;
  final String bannerName;
  final String image;

  Banner({
    required this.id,
    required this.bannerName,
    required this.image,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] as String,
      bannerName: json['banner_name'] as String,
      image: json['image'] as String,
    );
  }
}