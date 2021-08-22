import 'package:flutter/material.dart';
import 'package:ebook/app_localizations.dart';
import 'package:ebook/utils/constants.dart';
import 'package:ebook/utils/resources/colors.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../main.dart';

part 'AppStore.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  bool isDarkMode = false;

  @observable
  String selectedLanguageCode = defaultLanguage;

  @observable
  bool isNotificationOn = true;

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      setStatusBarColor(app_background_black);
    } else {
      setStatusBarColor(app_background);
    }
  }

  @action
  Future<void> setLanguage(String aSelectedLanguageCode,
      {BuildContext context}) async {
    selectedLanguageCode = aSelectedLanguageCode;

    language = languages
        .firstWhere((element) => element.languageCode == aSelectedLanguageCode);
    await setValue(LANGUAGE, aSelectedLanguageCode);

    if (context != null) {
      appLocalizations = AppLocalizations.of(context);
      errorThisFieldRequired = appLocalizations.translate('field_Required');
    }
  }

  @action
  void setNotification(bool val) {
    isNotificationOn = val;

    setValue(IS_NOTIFICATION_ON, val);

    if (isMobile) {
      OneSignal.shared.disablePush(!val);
    }
  }
}
