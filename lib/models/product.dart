class Product {
  final dynamic id;
  final dynamic name;
  final dynamic unit;
  final dynamic price;
  final dynamic max;
  final dynamic rating;
  final dynamic tamilName;
  final dynamic productBenefits;
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
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      price: json['price'],
      max: json['max'],
      rating: json['rating'],
      tamilName: json['tamil_name'],
      productBenefits: json['product_benefits'],
      images: (json['images'] as List<dynamic>).map((i) => i['image'] as String).toList(),
    );
  }
}
