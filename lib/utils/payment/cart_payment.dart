import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ebook/models/response/braintree_payment_responses.dart';
import 'package:ebook/models/response/checksum_response.dart';
import 'package:ebook/network/rest_apis.dart';
import 'package:ebook/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../common.dart';

class CartPayment {
  static const CHANNEL = "granth_payment";
  static const PAYPAL_CHANNEL = "granth_braintree_payment";
  static const CURRENCY_CODE = "USD";

  static const MethodChannel _channel = const MethodChannel(CHANNEL);
  static const MethodChannel _paypal_channel =
      const MethodChannel(PAYPAL_CHANNEL);

  static Future<void> payWithPayTm(
      context, totalAmount, orderDetail, paymentType) {
    return makePayment(context, totalAmount).then((result) {
      CheckSumResponse checksum = CheckSumResponse.fromJson(result);
      return proceesPaytmPayment(context, checksum, orderDetail);
    }).catchError((error) {
      throw error;
    });
  }

  static Future makePayment(context, total) {
    var request = {
      "TXN_AMOUNT": total.toString(),
      "EMAIL": 'test@gmail.com',
      "MOBILE_NO": '000000000',
    };
    return getChecksum(request);
  }

  static Future paywithPayPal(context, token, total, orderDetail) async {
    //TODO:recheck
    // BraintreePayment braintreePayment = new BraintreePayment();
    // var data = await braintreePayment.showDropIn(nonce: token, amount: total, enableGooglePay: false, nameRequired: true);
    var data = Map();
    print("Response of the payment $data");
    if (data["status"] == "fail") {
      throw data["message"];
    } else if (data["status"] == "success") {
      var request = {
        "payment_method_nonce": data["paymentNonce"],
        "amount": total
      };
      savePayPalTransaction(request).then((res) async {
        CreateTransactionResponse response =
            CreateTransactionResponse.fromJson(res);
        if (response.data.transaction != null) {
          Transaction transaction = response.data.transaction;
          makePayment(context, total).then((result) async {
            CheckSumResponse checksum = CheckSumResponse.fromJson(result);
            var transactionDetail = <String, String>{
              "BANKNAME": "NA",
              "ORDERID": checksum.data.orderData.orderID,
              "CHECKSUMHASH": checksum.data.checksumData.cHECKSUMHASH,
              "TXNAMOUNT": checksum.data.orderData.txnAmount.toString(),
              "TXNDATE": DateFormat("yyyy-MM-dd HH:mm:ss.0", "en_US")
                  .format(DateTime.now()),
              "MID": "NA",
              "TXNID": transaction.id,
              "PAYMENTMODE": PAYPAL,
              "CURRENCY": CURRENCY_CODE,
              "BANKTXNID": "NA",
              "GATEWAYNAME": "NA",
              "RESPMSG": transaction.processorResponseType,
              "STATUS": transaction.status == "settling" ||
                      transaction.status == "submitted_for_settlement"
                  ? "TXN_SUCCESS"
                  : "TXN_FAILURE",
            };

            log("transactionDetail :$transactionDetail");

            showTransactionDialog(
                context,
                transaction.status == "settling" ||
                    transaction.status == "submitted_for_settlement");

            return saveTransaction(transactionDetail, orderDetail, PAYPAL, 1);
          }).catchError((error) {
            throw error;
          });
        } else {
          throw "Unable to create a transaction." + response.message;
        }
      }).catchError((error) {
        throw error;
      });
    }
    print("======= true");
  }

  static Future proceesPaytmPayment(
      context, CheckSumResponse response, orderDetail) async {
    await startPayTmPayment(response).then((Map<dynamic, dynamic> inResponse) {
      print(jsonEncode(inResponse));
      if (inResponse.containsKey("error")) {
        throw inResponse["errorMessage"];
      } else {
        var status;
        if (inResponse["RESPCODE"] != null &&
            inResponse["RESPCODE"].toString() == "01") {
          status = 1;
        } else {
          status = 2;
        }
        var request = <String, String>{
          "BANKNAME": inResponse["BANKNAME"].toString(),
          "ORDERID": inResponse["ORDERID"].toString(),
          "CHECKSUMHASH": response.data.checksumData.cHECKSUMHASH,
          "TXNAMOUNT": inResponse["TXNAMOUNT"].toString(),
          "TXNDATE": inResponse["TXNDATE"].toString(),
          "MID": inResponse["MID"].toString(),
          "TXNID": inResponse["TXNID"].toString(),
          "PAYMENTMODE": inResponse["PAYMENTMODE"].toString(),
          "CURRENCY": inResponse["CURRENCY"].toString(),
          "BANKTXNID": inResponse["BANKTXNID"].toString(),
          "GATEWAYNAME": inResponse["GATEWAYNAME"].toString(),
          "RESPMSG": inResponse["RESPMSG"].toString(),
          "STATUS": inResponse["STATUS"].toString(),
        };
        showTransactionDialog(
            context, inResponse["STATUS"].toString() == "TXN_SUCCESS");

        return saveTransaction(request, orderDetail, PAYTM, status);
      }
    }).catchError((error) {
      throw error;
    });
  }

  static Future<Map<dynamic, dynamic>> startPayTmPayment(
      CheckSumResponse checkSumResponse) async {
    OrderData paytm = checkSumResponse.data.orderData;

    try {
      Map<dynamic, dynamic> response =
          await _channel.invokeMethod('startPaytmPayment', <String, dynamic>{
        "mId": paytm.mID.toString().trim(),
        "testing": true,
        'orderId': paytm.orderID.toString().trim(),
        'custId': paytm.cusID.toString().trim(),
        'channelId': paytm.channelId.toString().trim(),
        'txnAmount': paytm.txnAmount.toString().trim(),
        'website': paytm.wEBSITE.toString().trim(),
        'callBackUrl': paytm.callbackUrl.toString().trim(),
        'industryTypeId': paytm.industryTypeId.toString().trim(),
        'checkSumHash':
            checkSumResponse.data.checksumData.cHECKSUMHASH.toString().trim(),
        'email': paytm.eMAIL.toString().trim(),
        'mobile_no': paytm.mobileNo.toString().trim()
      });
      return response;
    } on PlatformException catch (e) {
      throw 'error: ${e.message}';
    }
  }

  static initializePayPAl(String clientToken) async {
    await _paypal_channel.invokeMethod(
        'initialize_paypal', <String, dynamic>{"client_token": clientToken});
  }

  static Future<Map<dynamic, dynamic>> startPayPalPayment(
      String totalAmount) async {
    try {
      Map<dynamic, dynamic> response = await _paypal_channel
          .invokeMethod('startPayPalPayment', <String, dynamic>{
        "total_amount": totalAmount,
        "currency_code": CURRENCY_CODE,
      });
      return response;
    } on PlatformException catch (e) {
      throw 'error: ${e.message}';
    }
  }
}
