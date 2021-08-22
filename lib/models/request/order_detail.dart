class OrderDetail {
    var bookId;
    var cashOnDelivery;
    var discount;
    var gstnumber;
    var isHardCopy;
    OtherDetail otherDetail;
    var paymentType;
    var quantity;
    var shippingCost;
    var totalAmount;
    var price;
    var userId;

    OrderDetail({this.bookId, this.cashOnDelivery, this.discount, this.gstnumber, this.isHardCopy, this.otherDetail, this.paymentType, this.quantity, this.shippingCost, this.totalAmount, this.price, this.userId});

    factory OrderDetail.fromJson(Map<String, dynamic> json) {
        return OrderDetail(
            bookId: json['book_id'], 
            cashOnDelivery: json['cash_on_delivery'], 
            discount: json['discount'], 
            gstnumber: json['gstnumber'], 
            isHardCopy: json['is_hard_copy'], 
            otherDetail: json['other_detail'] != null ? OtherDetail.fromJson(json['other_detail']) : null, 
            paymentType: json['payment_type'], 
            quantity: json['quantity'], 
            shippingCost: json['shipping_cost'], 
            totalAmount: json['total_amount'], 
            price: json['price'], 
            userId: json['user_id'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['book_id'] = this.bookId;
        data['cash_on_delivery'] = this.cashOnDelivery;
        data['discount'] = this.discount;
        data['gstnumber'] = this.gstnumber;
        data['is_hard_copy'] = this.isHardCopy;
        data['payment_type'] = this.paymentType;
        data['quantity'] = this.quantity;
        data['shipping_cost'] = this.shippingCost;
        data['total_amount'] = this.totalAmount;
        data['price'] = this.price;
        data['user_id'] = this.userId;
        if (this.otherDetail != null) {
            data['other_detail'] = this.otherDetail.toJson();
        }
        return data;
    }
}

class OtherDetail {
    List<BookData> data;

    OtherDetail({this.data});

    factory OtherDetail.fromJson(Map<String, dynamic> json) {
        return OtherDetail(
            data: json['data'] != null ? (json['data'] as List).map((i) => BookData.fromJson(i)).toList() : null,
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

class BookData {
    var book_id;
    var discount;
    var price;

    BookData({this.book_id, this.discount,this.price});

    factory BookData.fromJson(Map<String, dynamic> json) {
        return BookData(
            book_id: json['book_id'], 
            discount: json['discount'], 
            price: json['price'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['book_id'] = this.book_id;
        data['discount'] = this.discount;
        data['price'] = this.price;
        return data;
    }
}