class CategoryRes {
  String? success;
  String? error;
  String? messgae;
  List<Category>? category;

  CategoryRes({this.success, this.error, this.messgae, this.category});

  CategoryRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    messgae = json['messgae'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(new Category.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    data['messgae'] = this.messgae;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Category {
  String? id;
  String? name;
  String? description;
  String? images;

  Category({this.id, this.name, this.description, this.images});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    images = json['images'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['images'] = this.images;
    return data;
  }
}
