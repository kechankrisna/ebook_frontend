import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ebook/network/common_api_calls.dart';
import 'package:ebook/screens/about_app_screen.dart';
import 'package:ebook/screens/cart_screen.dart';
import 'package:ebook/screens/change_password_screen.dart';
import 'package:ebook/screens/feedback_screen.dart';
import 'package:ebook/screens/library_screen.dart';
import 'package:ebook/screens/profile_screen.dart';
import 'package:ebook/screens/setting_screen.dart';
import 'package:ebook/screens/sign_in_screen.dart';
import 'package:ebook/screens/transaction_history_screen.dart';
import 'package:ebook/screens/wishlist_screens.dart';
import 'package:ebook/utils/common.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/images.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

import '../app_localizations.dart';

class HomeDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeDrawerState();
  }
}

class HomeDrawerState extends State<HomeDrawer> {
  Color color;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    /// setStatusBarColor(color);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// setStatusBarColor(Theme.of(context).primaryColor);
    /// color = context.scaffoldBackgroundColor;
    Widget profileWidget() => Container(
          alignment: Alignment.bottomLeft,
          width: double.infinity,
          padding: EdgeInsets.all(12),

          /// color: Theme.of(context).primaryColor,
          child: getBoolAsync(IS_LOGGED_IN)
              ? GestureDetector(
                  onTap: () {
                    finish(context);
                    ProfileScreen().launch(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:
                              getStringAsync(USER_PROFILE).isNotEmpty
                                  ? NetworkImage(getStringAsync(USER_PROFILE))
                                  : AssetImage(ic_profile),
                          radius: 40,
                        ),
                        16.width,
                        Text(getStringAsync(USERNAME), style: boldTextStyle()),
                        8.height,
                        Text(getStringAsync(USER_EMAIL),
                            style: primaryTextStyle()),
                      ],
                    ),
                  ).expand())
              : GestureDetector(
                  onTap: () {
                    finish(context);
                    SignInScreen().launch(context);
                  },
                  child: Text(keyString(context, "lbl_login"),
                      style: boldTextStyle(
                        size: 24,
                      ))),
        );
    Widget body() => Column(
          children: <Widget>[
            profileWidget(),
            Divider(),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: Icon(MdiIcons.homeOutline),
              title: keyString(context, "lbl_dashboard"),
              onTap: () {
                finish(context);
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_book,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_my_library"),
              onTap: () {
                finish(context);
                LibraryScreen().launch(context);
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_cart,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_my_cart"),
              onTap: () {
                finish(context);
                CartScreen().launch(context);
              },
            ).visible(getBoolAsync(IS_LOGGED_IN)),
            Divider(height: 10, color: viewLineColor),
            Column(
              children: <Widget>[
                SettingItemWidget(
                  titleTextColor: context.theme.textTheme.headline6.color,
                  leading: SvgPicture.asset(
                    icon_bookmark,
                    width: 20,
                    height: 20,
                    color: context.theme.iconTheme.color,
                  ),
                  title: keyString(context, "lbl_wish_list"),
                  onTap: () {
                    finish(context);
                    WishlistScreen().launch(context);
                  },
                ),
                SettingItemWidget(
                  titleTextColor: context.theme.textTheme.headline6.color,
                  leading: SvgPicture.asset(
                    icon_bank,
                    width: 20,
                    height: 20,
                    color: context.theme.iconTheme.color,
                  ),
                  title: keyString(context, "lbl_transaction_history"),
                  onTap: () {
                    finish(context);
                    TransactionHistoryScreen().launch(context);
                  },
                ),
                SettingItemWidget(
                  titleTextColor: context.theme.textTheme.headline6.color,
                  leading: SvgPicture.asset(
                    icon_password,
                    width: 20,
                    height: 20,
                    color: context.theme.iconTheme.color,
                  ),
                  title: keyString(context, "lbl_change_password"),
                  onTap: () {
                    finish(context);
                    ChangePasswordScreen().launch(context);
                  },
                ),
                SettingItemWidget(
                  titleTextColor: context.theme.textTheme.headline6.color,
                  leading: SvgPicture.asset(
                    icon_logout,
                    width: 20,
                    height: 20,
                    color: context.theme.iconTheme.color,
                  ),
                  title: keyString(context, "lbl_logout"),
                  onTap: () async {
                    showConfirmDialogCustom(
                      context,
                      onAccept: (_) {
                        finish(context);
                        doLogout(context);
                      },
                      title: keyString(context, "msg_logout"),
                      positiveText: 'logout',
                    );
                  },
                ),
                Divider(
                  height: 20,
                ),
              ],
            ).visible(getBoolAsync(IS_LOGGED_IN)),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_settings,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "settings"),
              onTap: () {
                finish(context);
                SettingScreen().launch(context);
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_share,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_share_app"),
              onTap: () {
                Share.share('check out my website https://google.com');
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_rate,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_rate_app"),
              onTap: () {
                launchUrl(playStoreBaseURL + "com.iqonic.fluttergranth");
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_shield,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_privacy_policy"),
              onTap: () {
                launchUrl("https://www.google.com");
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_contract,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_terms_amp_condition"),
              onTap: () {
                launchUrl("https://www.google.com");
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_blog,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_feedback"),
              onTap: () {
                finish(context);
                FeedbackScreen().launch(context);
              },
            ),
            SettingItemWidget(
              titleTextColor: context.theme.textTheme.headline6.color,
              leading: SvgPicture.asset(
                icon_info,
                width: 20,
                height: 20,
                color: context.theme.iconTheme.color,
              ),
              title: keyString(context, "lbl_about_app"),
              onTap: () {
                finish(context);
                AboutApp().launch(context);
              },
            ),
            16.height,
          ],
        );
    return Drawer(
      elevation: 8,
      child: Container(
        color: context.scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            child: body(),
          ),
        ),
      ),
    );
  }
}
