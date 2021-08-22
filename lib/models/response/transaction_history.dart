import 'dart:convert';

class TransactionHistory {
  List<Transaction> transcationData;

  TransactionHistory({this.transcationData});

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      transcationData: json['data'] != null ? (json['data'] as List).map((i) => Transaction.fromJson(i)).toList() : null,
    );
  }
}

/*class Transaction {
  int bookId;
  String bookName;
  String bookTitle;
  String front_cover;
  double cgst;
  double igst;
  int isHardCopy;
  String otherTransactionDetail;
  String paymentStatus;
  int quantity;
  double sgst;
  double shippingCost;
  double totalAmount;
  String txnId;
  int userId;

  Transaction(
      {this.bookId,
      this.bookName,
      this.bookTitle,
      this.cgst,
      this.igst,
      this.isHardCopy,
      this.otherTransactionDetail,
      this.paymentStatus,
      this.quantity,
      this.sgst,
      this.shippingCost,
      this.totalAmount,
      this.txnId,
      this.userId,this.front_cover});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      bookId: json['book_id'],
      bookName: json['book_name'],
      bookTitle: json['book_title'],
      cgst: json['cgst'],
      igst: json['igst'],
      isHardCopy: json['is_hard_copy'],
      otherTransactionDetail: json['other_transaction_detail'],
      paymentStatus: json['payment_status'],
      quantity: json['quantity'],
      sgst: json['sgst'],
      shippingCost: json['shipping_cost'],
      totalAmount: json['total_amount'],
      txnId: json['txn_id'],
      userId: json['user_id'],
      front_cover: json['front_cover'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['book_id'] = this.bookId;
    data['book_name'] = this.bookName;
    data['book_title'] = this.bookTitle;
    data['cgst'] = this.cgst;
    data['igst'] = this.igst;
    data['is_hard_copy'] = this.isHardCopy;
    data['other_transaction_detail'] = this.otherTransactionDetail;
    data['payment_status'] = this.paymentStatus;
    data['quantity'] = this.quantity;
    data['sgst'] = this.sgst;
    data['shipping_cost'] = this.shippingCost;
    data['total_amount'] = this.totalAmount;
    data['txn_id'] = this.txnId;
    data['user_id'] = this.userId;
    return data;
  }
}


*/

class Transaction {
  var bookId;
  var bookName;
  var bookTitle;
  var frontCover;
  var price;
  var discount;
  var totalAmount;
  var paymentType;
  var txnId;
  var paymentStatus;
  OtherDetail otherTransactionDetail;

  Transaction(
      {this.bookId,
      this.bookName,
      this.bookTitle,
      this.frontCover,
      this.price,
      this.discount,
      this.totalAmount,
      this.paymentType,
      this.txnId,
      this.paymentStatus,
      this.otherTransactionDetail});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      bookId: json['book_id'],
      bookName: json['book_name'],
      bookTitle: json['book_title'],
      frontCover: json['front_cover'] != null ? json['front_cover'] : null,
      price: json['price'],
      discount: json['discount'],
      totalAmount: json['total_amount'],
      paymentType: json['payment_type'],
      txnId: json['txn_id'],
      paymentStatus: json['payment_status'],
      otherTransactionDetail: json['other_transaction_detail'] != null ? OtherDetail.fromJson(jsonDecode(json['other_transaction_detail'])) : null,
    );
  }
}

class OtherDetail {
  String bANKNAME;
  String oRDERID;
  String tXNAMOUNT;
  String tXNDATE;
  String mID;
  String tXNID;
  String pAYMENTMODE;
  String cURRENCY;
  String bANKTXNID;
  String gATEWAYNAME;
  String rESPMSG;
  String sTATUS;

  OtherDetail(
      {this.bANKNAME, this.oRDERID, this.tXNAMOUNT, this.tXNDATE, this.mID, this.tXNID, this.pAYMENTMODE, this.cURRENCY, this.bANKTXNID, this.gATEWAYNAME, this.rESPMSG, this.sTATUS});

  factory OtherDetail.fromJson(Map<String, dynamic> json) {
    return OtherDetail(
      bANKNAME: json['BANKNAME'],
      oRDERID: json['ORDERID'],
      tXNAMOUNT: json['TXNAMOUNT'],
      tXNDATE: json['TXNDATE'],
      mID: json['MID'],
      tXNID: json['TXNID'],
      pAYMENTMODE: json['PAYMENTMODE'],
      cURRENCY: json['CURRENCY'],
      bANKTXNID: json['BANKTXNID'],
      gATEWAYNAME: json['GATEWAYNAME'],
      rESPMSG: json['RESPMSG'],
      sTATUS: json['STATUS'],
    );
  }
}
