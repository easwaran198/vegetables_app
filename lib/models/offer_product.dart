import 'package:vegetables_app/models/image_model.dart';

class OfferProduct {
  final dynamic id;
  final dynamic name;
  final dynamic unit;
  final dynamic price;
  final dynamic rating;
  final dynamic tamilName;
  final dynamic productBenefits;
  final List<ImageModel> images;

  OfferProduct({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.rating,
    required this.tamilName,
    required this.productBenefits,
    required this.images,
  });

  factory OfferProduct.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imageListJson = json['images'] ?? []; // Handle potential null 'images' list
    final List<ImageModel> parsedImages =
    imageListJson.map((imageData) => ImageModel.fromJson(imageData as Map<String, dynamic>)).toList();

    return OfferProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      price: json['price'] as String,
      // Safely parse rating, it can be int or double in JSON.
      // Use .toDouble() to ensure it's a double.
      rating: json['rating'] as String,
      tamilName: json['tamil_name'] as String,
      productBenefits: json['product_benefits'] as String,
      images: parsedImages, // Assign the parsed list of ImageModel
    );
  }
}