class Product {
  final String id;
  final String name;
  final String unit;
  final String price;
  final String max;
  final String rating;
  final String tamilName;
  final String productBenefits;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.max,
    required this.rating,
    required this.tamilName,
    required this.productBenefits,
    required this.images,
  });


  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      price: json['price'] as String,
      max: json['max'] as String,
      rating: json['rating'] as String,
      tamilName: json['tamil_name'] as String,
      productBenefits: json['product_benefits'] as String,
      // Map the list of image objects to a list of image URLs
      images: (json['images'] as List<dynamic>)
          .map((imageJson) => imageJson['image'] as String)
          .toList(),
    );
  }
}