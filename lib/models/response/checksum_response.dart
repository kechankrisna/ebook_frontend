class CheckSumResponse {
  CheckSum data;

  CheckSumResponse({this.data});

  factory CheckSumResponse.fromJson(Map<String, dynamic> json) {
    return CheckSumResponse(
      data: json['data'] != null ? CheckSum.fromJson(json['data']) : null,
    );
  }
}

class CheckSum {
  OrderData orderData;
  ChecksumData checksumData;

  CheckSum({this.orderData, this.checksumData});

  factory CheckSum.fromJson(Map<String, dynamic> json) {
    return CheckSum(
      orderData: json['order_data'] != null ? OrderData.fromJson(json['order_data']) : null,
      checksumData: json['checksum_data'] != null ? ChecksumData.fromJson(json['checksum_data']) : null,
    );
  }
}

class ChecksumData {
  var cHECKSUMHASH;
  var orderID;
  var paytStatus;

  ChecksumData({this.cHECKSUMHASH, this.orderID, this.paytStatus});

  factory ChecksumData.fromJson(Map<String, dynamic> json) {
    return ChecksumData(
      cHECKSUMHASH: json['CHECKSUMHASH'],
      orderID: json['ORDER_ID'],
      paytStatus: json['PAYT_STATUS'],
    );
  }
}

class OrderData {
  var mID;
  var orderID;
  var cusID;
  var industryTypeId;
  var channelId;
  var txnAmount;
  var callbackUrl;
  var wEBSITE;
  var eMAIL;
  var mobileNo;

  OrderData({this.mID, this.orderID, this.cusID, this.industryTypeId, this.channelId, this.txnAmount, this.callbackUrl, this.wEBSITE, this.eMAIL, this.mobileNo});

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      mID: json['MID'],
      orderID: json['ORDER_ID'],
      cusID: json['CUST_ID'],
      industryTypeId: json['INDUSTRY_TYPE_ID'],
      channelId: json['CHANNEL_ID'],
      txnAmount: json['TXN_AMOUNT'],
      callbackUrl: json['CALLBACK_URL'],
      wEBSITE: json['WEBSITE'],
      eMAIL: json['EMAIL'],
      mobileNo: json['MOBILE_NO'],
    );
  }
}
