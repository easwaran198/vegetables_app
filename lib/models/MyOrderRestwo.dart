class MyOrderRestwo {
  String? success;
  String? error;
  String? message;
  List<Orders>? orders;

  MyOrderRestwo({this.success, this.error, this.message, this.orders});

  MyOrderRestwo.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  int? orderId;
  String? orderNo;
  String? orderDate;
  String? orderTime;
  String? totalAmount;
  String? orderStatus;
  int? productCount;

  Orders(
      {this.orderId,
        this.orderNo,
        this.orderDate,
        this.orderTime,
        this.totalAmount,
        this.orderStatus,
        this.productCount});

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderNo = json['order_no'];
    orderDate = json['order_date'];
    orderTime = json['order_time'];
    totalAmount = json['total_amount'];
    orderStatus = json['order_status'];
    productCount = json['product_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['order_no'] = this.orderNo;
    data['order_date'] = this.orderDate;
    data['order_time'] = this.orderTime;
    data['total_amount'] = this.totalAmount;
    data['order_status'] = this.orderStatus;
    data['product_count'] = this.productCount;
    return data;
  }
}
