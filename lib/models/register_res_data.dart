class RegisterResData {
  String? success;
  String? error;
  String? otp;
  String? token;
  String? message;

  RegisterResData(
      {this.success, this.error, this.otp, this.token, this.message});

  RegisterResData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    otp = json['otp'];
    token = json['token'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    data['otp'] = this.otp;
    data['token'] = this.token;
    data['message'] = this.message;
    return data;
  }
}
