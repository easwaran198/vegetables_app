// lib/models/product.dart (Update this file)
import 'package:vegetables_app/models/image_model.dart'; // Import the new ImageModel

class OfferProduct {
  final String id;
  final String name;
  final String unit;
  final String price;
  final double rating; // Changed to double based on your response
  final String tamilName;
  final String productBenefits;
  final List<ImageModel> images; // Change to List of ImageModel

  OfferProduct({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.rating,
    required this.tamilName,
    required this.productBenefits,
    required this.images, // Now a List<ImageModel>
  });

  factory OfferProduct.fromJson(Map<String, dynamic> json) {
    // Parse the 'images' list
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
      rating: (json['rating'] as num).toDouble(),
      tamilName: json['tamil_name'] as String,
      productBenefits: json['product_benefits'] as String,
      images: parsedImages, // Assign the parsed list of ImageModel
    );
  }
}