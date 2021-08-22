package com.iqonic.fluttergranth.paytm

import android.app.Activity
import android.os.Bundle
import android.util.Log
import com.paytm.pgsdk.PaytmOrder
import com.paytm.pgsdk.PaytmPGService
import com.paytm.pgsdk.PaytmPaymentTransactionCallback
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class PaytmPlugin private constructor(private val activity: Activity) : MethodChannel.MethodCallHandler {
    var TAG = javaClass.name
    var result: MethodChannel.Result? = null
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        this.result = result
        if (call.method == "startPaytmPayment") {
            val testing = call.argument<Boolean>("testing")!!
            val mId = call.argument<Any>("mId").toString()
            val orderId = call.argument<Any>("orderId").toString()
            val custId = call.argument<Any>("custId").toString()
            val channelId = call.argument<Any>("channelId").toString()
            val txnAmount = call.argument<Any>("txnAmount").toString()
            val website = call.argument<Any>("website").toString()
            val callBackUrl = call.argument<Any>("callBackUrl").toString()
            val industryTypeId = call.argument<Any>("industryTypeId").toString()
            val checkSumHash = call.argument<Any>("checkSumHash").toString()
            val email = call.argument<Any>("email").toString()
            val mobile = call.argument<Any>("mobile_no").toString()
            initializePaytmPayment(testing, mId, orderId, custId, channelId, txnAmount, website, callBackUrl, industryTypeId, checkSumHash, email, mobile)
        } else {
            result.notImplemented()
        }
    }

    private fun sendResponse(paramMap: Map<String, Any?>) {
        result!!.success(paramMap)
    }

    private fun initializePaytmPayment(testing: Boolean, mId: String,orderId: String,custId: String,channelId: String,txnAmount: String,website: String,callBackUrl: String,industryTypeId: String,checkSumHash: String,email: String,mobile: String) {
        val paytmPGService: PaytmPGService = if (testing) {
            PaytmPGService.getStagingService()
        } else {
            PaytmPGService.getProductionService()
        }
        val paramMap = HashMap<String, String>()
        paramMap["MID"] = mId
        paramMap["ORDER_ID"] = orderId
        paramMap["CUST_ID"] = custId
        paramMap["CHANNEL_ID"] = channelId
        paramMap["TXN_AMOUNT"] = txnAmount
        paramMap["WEBSITE"] = website
        paramMap["CALLBACK_URL"] = callBackUrl
        paramMap["CHECKSUMHASH"] = checkSumHash
        paramMap["INDUSTRY_TYPE_ID"] = industryTypeId
        paramMap["MOBILE_NO"] = mobile
        paramMap["EMAIL"] = email
        val order = PaytmOrder(paramMap)
        paytmPGService.initialize(order, null)
        paytmPGService.startPaymentTransaction(activity, true, true, object : PaytmPaymentTransactionCallback {
            override fun onTransactionResponse(bundle: Bundle) {
                Log.i(TAG, bundle.toString())
                val paramMap: MutableMap<String, Any?> = HashMap()
                for (key in bundle.keySet()) {
                    paramMap[key] = bundle.get(key)
                }
                Log.i(TAG, paramMap.toString())
                sendResponse(paramMap)
            }

            override fun networkNotAvailable() {
                val paramMap: MutableMap<String, Any> = HashMap()
                paramMap["error"] = true
                paramMap["errorMessage"] = "Network Not Available"
                sendResponse(paramMap)
            }

            override fun clientAuthenticationFailed(s: String) {
                val paramMap: MutableMap<String, Any> = HashMap()
                paramMap["error"] = true
                paramMap["errorMessage"] = s
                sendResponse(paramMap)
            }

            override fun someUIErrorOccurred(s: String) {
                val paramMap: MutableMap<String, Any> = HashMap()
                paramMap["error"] = true
                paramMap["errorMessage"] = s
                sendResponse(paramMap)
            }

            override fun onErrorLoadingWebPage(i: Int, s: String, s1: String) {
                val paramMap: MutableMap<String, Any> = HashMap()
                paramMap["error"] = true
                paramMap["errorMessage"] = "$s , $s1"
                sendResponse(paramMap)
            }

            override fun onBackPressedCancelTransaction() {
                val paramMap: MutableMap<String, Any> = HashMap()
                paramMap["error"] = true
                paramMap["errorMessage"] = "Back Pressed Transaction Cancelled"
                sendResponse(paramMap)
            }

            override fun onTransactionCancel(s: String, bundle: Bundle) {
                Log.i(TAG, s + bundle.toString())
                val paramMap: MutableMap<String, Any?> = HashMap()
                for (key in bundle.keySet()) {
                    paramMap[key] = bundle.getString(key)
                }
                Log.i(TAG, paramMap.toString())
                paramMap["error"] = true
                paramMap["errorMessage"] = s
                sendResponse(paramMap)
            }
        })
    }

    companion object {
        fun registerWith(activity: Activity, flutterEngine: FlutterEngine) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "granth_payment")
            channel.setMethodCallHandler(PaytmPlugin(activity))
        }
    }

}