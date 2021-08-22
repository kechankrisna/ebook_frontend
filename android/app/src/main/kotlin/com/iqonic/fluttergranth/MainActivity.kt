package com.iqonic.fluttergranth


import androidx.annotation.NonNull
//import com.iqonic.fluttergranth.epub_kitty.EpubKittyPlugin
//import com.iqonic.granth_flutter.braintree.BrainTreePaymentPlugin
import com.iqonic.fluttergranth.paytm.PaytmPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity(){

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        PaytmPlugin.registerWith(this, flutterEngine);
//        EpubKittyPlugin.registerWith(this, flutterEngine);
//        BrainTreePaymentPlugin.registerWith(this, flutterEngine);

    }


}
