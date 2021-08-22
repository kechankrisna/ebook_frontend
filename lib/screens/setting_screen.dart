import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ebook/app_localizations.dart';
import 'package:ebook/component/app_language_dialog.dart';
import 'package:ebook/main.dart';
import 'package:ebook/screens/choose_detail_page_variant_screen.dart';
import 'package:ebook/utils/admob_utils.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/colors.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingScreen extends StatefulWidget {
  static String tag = '/SettingScreen';

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  var selectedLanguage = 0;
  bool isSwitched = false;
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    init();
    _bannerAd = createBannerAd()..load();
  }

  init() async {
    selectedLanguage = getIntAsync(SELECTED_LANGUAGE_INDEX);
    isSwitched = getBoolAsync(IS_DARK_THEME);

    setState(() {});
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: context.scaffoldBackgroundColor,
      iconTheme: context.theme.iconTheme,
      centerTitle: true,
      title: Text(keyString(context, "settings"),
          style: boldTextStyle(color: context.theme.textTheme.headline6.color)),
    );
    final body = Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          SettingItemWidget(
            padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
            leading: SvgPicture.asset(icon_logotype, height: 20, width: 20),
            title: keyString(context, 'language'),
            titleTextStyle:
                boldTextStyle(color: context.theme.textTheme.headline6.color),
            onTap: () {
              return showInDialog(
                context,
                child: AppLanguageDialog(),
                contentPadding: EdgeInsets.zero,
                title: Text("Select " + keyString(context, "language"),
                    style: boldTextStyle(size: 20)),
              );
            },
            trailing: Container(
              child: Row(
                children: [
                  Image.asset(language.flag, height: 40, width: 40),
                  16.width,
                  Text(language.name.validate(),
                      style: boldTextStyle(
                          color: context.theme.textTheme.headline6.color)),
                ],
              ),
            ),
          ),
          Divider(),
          SettingItemWidget(
            padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
            leading:
                SvgPicture.asset(icon_miscellaneous, height: 28, width: 28),
            titleTextStyle:
                boldTextStyle(color: context.theme.textTheme.headline6.color),
            title: keyString(context, 'night_mode'),
            onTap: () async {
              isSwitched = !isSwitched;

              setBoolAsync(IS_DARK_THEME, isSwitched);
              if (isSwitched) {
                appStore.setDarkMode(true);
              } else {
                appStore.setDarkMode(false);
              }

              setState(() {});
            },
            trailing: CupertinoSwitch(
              value: isSwitched,
              onChanged: (value) async {
                isSwitched = !isSwitched;

                setBoolAsync(IS_DARK_THEME, isSwitched);
                if (isSwitched) {
                  appStore.setDarkMode(true);
                } else {
                  appStore.setDarkMode(false);
                }
              },
              activeColor: color_primary_black,
            ),
          ),
          Divider(),
          SettingItemWidget(
            leading: Icon(Icons.check_circle_outline_outlined),
            title: "Choose detail page variant",
            titleTextStyle:
                boldTextStyle(color: context.theme.textTheme.headline6.color),
            onTap: () {
              ChooseDetailPageVariantScreen().launch(context);
            },
          ),
          Observer(
            builder: (_) => SettingItemWidget(
              leading: Icon(
                  appStore.isNotificationOn ? Feather.bell : Feather.bell_off),
              title:
                  '${appStore.isNotificationOn ? 'Disable' : 'Enable'} Push Notification',
              titleTextStyle:
                  boldTextStyle(color: context.theme.textTheme.headline6.color),
              trailing: CupertinoSwitch(
                activeColor: colorPrimary,
                value: appStore.isNotificationOn,
                onChanged: (v) {
                  appStore.setNotification(v);
                },
              ).withHeight(10),
              onTap: () {
                appStore.setNotification(
                    !getBoolAsync(IS_NOTIFICATION_ON, defaultValue: true));
              },
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: appBar,
      body: Stack(
        children: [
          body,
          if (_bannerAd != null)
            Positioned(
              bottom: 0,
              child: AdWidget(ad: _bannerAd),
              height: AdSize.banner.height.toDouble(),
              width: context.width(),
            ),
        ],
      ),
    );
  }
}
