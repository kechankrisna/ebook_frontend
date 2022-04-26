import 'package:flutter/material.dart';
import 'package:ebook/app_localizations.dart';
import 'package:ebook/screens/home_screen.dart';
import 'package:ebook/screens/walkthrough_screen.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:nb_utils/nb_utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await initialize();
    checkScreen();
    setStatusBarColor(Colors.transparent);
  }

  void checkScreen() async {
    await 3.seconds.delay;
    if (getBoolAsync(IS_ONBOARDING_LAUNCHED)) {
      HomeScreen().launch(context, isNewTask: true);
    } else {
      WalkthroughScreen().launch(context, isNewTask: true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(splash_bg,
              height: context.height(),
              width: context.width(),
              fit: BoxFit.cover),
          Container(
              height: context.height(),
              width: context.width(),
              color: Colors.black.withOpacity(0.6)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(app_icon,
                      alignment: Alignment.center, height: 120, width: 120)
                  .cornerRadiusWithClipRRect(10),
              Text(keyString(context, "app_name"),
                      style: boldTextStyle(size: 24, color: Colors.white))
                  .paddingOnly(top: 16),
              Text(keyString(context, "lbl_welcome_to_ebook"),
                      style: primaryTextStyle(color: Colors.white))
                  .paddingOnly(top: 8),
            ],
          )
        ],
      ),
    );
  }
}
