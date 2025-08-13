// lib/models/image_model.dart (Create this new file)
class ImageModel {
  final String imageUrl;

  ImageModel({required this.imageUrl});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imageUrl: json['image'] as String,
    );
  }
}