import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ebook/models/language_model.dart';
import 'package:ebook/screens/splash_screen.dart';
import 'package:ebook/store/AppStore.dart';
import 'package:ebook/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'app_localizations.dart';
import 'app_theme.dart';

AppStore appStore = AppStore();

Language language;
List<Language> languages = Language.getLanguages();
AppLocalizations appLocalizations;
int mAdShowCount = 0;
// OneSignal oneSignal = OneSignal();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterDownloader.initialize(debug: true);
  }
  await initialize();

  if (getBoolAsync(IS_DARK_THEME)) {
    appStore.setDarkMode(true);
  } else {
    appStore.setDarkMode(false);
  }

  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));
  appStore
      .setNotification(getBoolAsync(IS_NOTIFICATION_ON, defaultValue: true));

  // await OneSignal.shared.setAppId(oneSignalAppId);

  // OneSignal.shared.setNotificationWillShowInForegroundHandler(
  //     (OSNotificationReceivedEvent event) {
  //   return event?.complete(event.notification);
  // });

  // oneSignal.disablePush(false);

  // oneSignal.consentGranted(true);
  // oneSignal.requiresUserPrivacyConsent();

  if (Platform.isAndroid) {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode),
        supportedLocales: Language.languagesLocale(),
        home: SplashScreen(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        builder: scrollBehaviour(),
      ),
    );
  }
}
