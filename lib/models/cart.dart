class CartResponse {
  String? success;
  String? error;
  String? message;
  String? totalQty;
  String? totalAmount;
  List<Cart>? cart;

  CartResponse(
      {this.success,
        this.error,
        this.message,
        this.totalQty,
        this.totalAmount,
        this.cart});

  CartResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    totalQty = json['total_qty'];
    totalAmount = json['total_amount'];
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
    data['total_qty'] = this.totalQty;
    data['total_amount'] = this.totalAmount;
    if (this.cart != null) {
      data['cart'] = this.cart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  String? id;
  String? productId;
  String? productName;
  String? unit;
  String? price;
  String? qty;
  String? amount;
  List<Image>? image;

  Cart(
      {this.id,
        this.productId,
        this.productName,
        this.unit,
        this.price,
        this.qty,
        this.amount,
        this.image});

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    productName = json['product_name'];
    unit = json['unit'];
    price = json['price'];
    qty = json['qty'];
    amount = json['amount'];
    if (json['image'] != null) {
      image = <Image>[];
      json['image'].forEach((v) {
        image!.add(new Image.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['unit'] = this.unit;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['amount'] = this.amount;
    if (this.image != null) {
      data['image'] = this.image!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Image {
  String? image;

  Image({this.image});

  Image.fromJson(Map<String, dynamic> json) {
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    return data;
  }
}
