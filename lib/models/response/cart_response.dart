class CartResponse {
  List<CartItem> data;

  CartResponse({this.data});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      data: json['data'] != null ? (json['data'] as List).map((i) => CartItem.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CartItem {
  var addedQty;
  var authorName;
  var bookId;
  var cartMappingId;
  var cashOnDelivery;
  var cgst;
  var discount;
  var frontCover;
  var igst;
  var inStock;
  var inventoryId;
  var name;
  var price;
  var sgst;
  var shippingCost;
  var title;
  var userId;

  CartItem(
      {this.addedQty,
      this.authorName,
      this.bookId,
      this.cartMappingId,
      this.cashOnDelivery,
      this.cgst,
      this.discount,
      this.frontCover,
      this.igst,
      this.inStock,
      this.inventoryId,
      this.name,
      this.price,
      this.sgst,
      this.shippingCost,
      this.title,
      this.userId});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      addedQty: json['added_qty'],
      authorName: json['author_name'],
      bookId: json['book_id'],
      cartMappingId: json['cart_mapping_id'],
      cashOnDelivery: json['cash_on_delivery'],
      cgst: json['cgst'],
      discount: json['discount'],
      frontCover: json['front_cover'],
      igst: json['igst'],
      inStock: json['in_stock'],
      inventoryId: json['inventory_id'],
      name: json['name'],
      price: json['price'],
      sgst: json['sgst'],
      shippingCost: json['shipping_cost'],
      title: json['title'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['added_qty'] = this.addedQty;
    data['author_name'] = this.authorName;
    data['book_id'] = this.bookId;
    data['cart_mapping_id'] = this.cartMappingId;
    data['cash_on_delivery'] = this.cashOnDelivery;
    data['cgst'] = this.cgst;
    data['discount'] = this.discount;
    data['front_cover'] = this.frontCover;
    data['igst'] = this.igst;
    data['in_stock'] = this.inStock;
    data['inventory_id'] = this.inventoryId;
    data['name'] = this.name;
    data['price'] = this.price;
    data['sgst'] = this.sgst;
    data['shipping_cost'] = this.shippingCost;
    data['title'] = this.title;
    data['user_id'] = this.userId;
    return data;
  }
}
