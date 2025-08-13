class MyOrderRestwo {
  String? success;
  String? error;
  String? message;
  List<Cart>? cart;

  MyOrderRestwo({this.success, this.error, this.message, this.cart});

  MyOrderRestwo.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['cart'] != null) {
      cart = <Cart>[];
      json['cart'].forEach((v) {
        cart!.add(new Cart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.cart != null) {
      data['cart'] = this.cart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  String? id;
  String? name;
  String? price;
  String? rating;
  String? totalPrice;
  String? tamilName;
  String? productBenefits;
  String? image;
  String? orderStatus;

  Cart(
      {this.id,
        this.name,
        this.price,
        this.rating,
        this.totalPrice,
        this.tamilName,
        this.productBenefits,
        this.orderStatus,
        this.image});

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    rating = json['rating'];
    totalPrice = json['total_price'];
    tamilName = json['tamil_name'];
    productBenefits = json['product_benefits'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['rating'] = this.rating;
    data['total_price'] = this.totalPrice;
    data['tamil_name'] = this.tamilName;
    data['product_benefits'] = this.productBenefits;
    data['image'] = this.image;
    return data;
  }
}
