class UpdateProfileRes {
  String? success;
  String? error;
  String? userid;
  String? message;

  UpdateProfileRes({this.success, this.error, this.userid, this.message});

  UpdateProfileRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    userid = json['userid'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    data['userid'] = this.userid;
    data['message'] = this.message;
    return data;
  }
}
