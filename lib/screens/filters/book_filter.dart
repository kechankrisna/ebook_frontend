import 'dart:convert';

class BookFilter {
  int page;
  int perPage;
  int categoryId;
  int subcategoryId;
  int authorId;
  double maxPrice;
  double minPrice;
  double rating;
  String searchText;
  BookFilter({
    this.page = 1,
    this.perPage = 12,
    this.categoryId,
    this.subcategoryId,
    this.authorId,
    this.maxPrice,
    this.minPrice,
    this.rating,
    this.searchText,
  });

  factory BookFilter.instance() => BookFilter();

  BookFilter copyWith({
    int page,
    int perPage,
    int categoryId,
    int subcategoryId,
    int authorId,
    double maxPrice,
    double minPrice,
    double rating,
    String searchText,
  }) {
    return BookFilter(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      authorId: authorId ?? this.authorId,
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      rating: rating ?? this.rating,
      searchText: searchText ?? this.searchText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'per_page': perPage,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'author_id': authorId,
      'max_price': maxPrice,
      'min_price': minPrice,
      'rating': rating,
      'search_text': searchText,
    };
  }

  factory BookFilter.fromMap(Map<String, dynamic> map) {
    return BookFilter(
      page: map['page']?.toInt() ?? 0,
      perPage: map['per_page']?.toInt() ?? 0,
      categoryId: map['category_id']?.toInt() ?? null,
      subcategoryId: map['subcategory_id']?.toInt() ?? null,
      authorId: map['author_id']?.toInt() ?? null,
      maxPrice: map['max_price']?.toDouble() ?? null,
      minPrice: map['min_price']?.toDouble() ?? null,
      rating: map['rating']?.toDouble() ?? null,
      searchText: map['search_text'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BookFilter.fromJson(String source) =>
      BookFilter.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BookFilter(page: $page, perPage: $perPage, categoryId: $categoryId, subcategoryId: $subcategoryId, authorId: $authorId, maxPrice: $maxPrice, minPrice: $minPrice, rating: $rating, searchText: $searchText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookFilter &&
        other.page == page &&
        other.perPage == perPage &&
        other.categoryId == categoryId &&
        other.subcategoryId == subcategoryId &&
        other.authorId == authorId &&
        other.maxPrice == maxPrice &&
        other.minPrice == minPrice &&
        other.rating == rating &&
        other.searchText == searchText;
  }

  @override
  int get hashCode {
    return page.hashCode ^
        perPage.hashCode ^
        categoryId.hashCode ^
        subcategoryId.hashCode ^
        authorId.hashCode ^
        maxPrice.hashCode ^
        minPrice.hashCode ^
        rating.hashCode ^
        searchText.hashCode;
  }
}
