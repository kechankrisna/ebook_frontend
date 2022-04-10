import 'package:ebook/models/response/category.dart';

class MainCategory {
  int categoryId;
  String name;
  String status;
  int total_book;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;

  MainCategory({
    this.categoryId,
    this.createdAt,
    this.deletedAt,
    this.name,
    this.status,
    this.updatedAt,
  });

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    return MainCategory(
      categoryId: json['category_id'],
      name: json['name'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
    );
  }

  Category toCategory() {
    return Category(
      status: this.status,
      subCategoryId: null,
      categoryId:this.categoryId,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      name: this.name,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['created_at'] = this.createdAt;
    data['name'] = this.name;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class MainCategoryResponse {
  List<MainCategory> data;

  MainCategoryResponse({this.data});

  factory MainCategoryResponse.fromJson(Map<String, dynamic> json) {
    return MainCategoryResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => MainCategory.fromJson(i)).toList()
          : null,
    );
  }
}
