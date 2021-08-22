import 'package:ebook/models/response/base_response.dart';

class WishListResponse extends BaseResponse {
  List<WishListItem> data;

  WishListResponse({this.data});

  factory WishListResponse.fromJson(Map<String, dynamic> json) {
    return WishListResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => WishListItem.fromJson(i)).toList()
          : null,
    );
  }
}

class WishListItem {
  var authorName;
  var backCover;
  var bookId;
  var categoryName;
  var dateOfPublication;
  var description;
  var discount;
  var discountedPrice;
  var edition;
  var filePath;
  var fileSamplePath;
  var format;
  var frontCover;
  var isWishlist;
  var keywords;
  var language;
  var name;
  var price;
  var publisher;
  var subcategoryName;
  var title;
  var topicCover;

  WishListItem(
      {this.authorName,
      this.backCover,
      this.bookId,
      this.categoryName,
      this.dateOfPublication,
      this.description,
      this.discount,
      this.discountedPrice,
      this.edition,
      this.filePath,
      this.fileSamplePath,
      this.format,
      this.frontCover,
      this.isWishlist,
      this.keywords,
      this.language,
      this.name,
      this.price,
      this.publisher,
      this.subcategoryName,
      this.title,
      this.topicCover});

  factory WishListItem.fromJson(Map<String, dynamic> json) {
    return WishListItem(
      authorName: json['author_name'],
      backCover: json['back_cover'],
      bookId: json['book_id'],
      categoryName: json['category_name'],
      dateOfPublication: json['date_of_publication'],
      description: json['description'],
      discount: json['discount'],
      discountedPrice: json['discounted_price'],
      edition: json['edition'] != null,
      filePath: json['file_path'],
      fileSamplePath: json['file_sample_path'],
      format: json['format'],
      frontCover: json['front_cover'],
      isWishlist: json['is_wishlist'],
      keywords: json['keywords'],
      language: json['language'],
      name: json['name'],
      price: json['price'],
      publisher: json['publisher'],
      subcategoryName: json['subcategory_name'],
      title: json['title'],
      topicCover: json['topic_cover'] != null,
    );
  }
}
