import 'package:flutter/material.dart';

class Language {
  int id;
  String name;
  String languageCode;
  String countryCode;
  String flag;

  Language(this.id, this.name, this.languageCode, this.countryCode, this.flag);

  static List<Language> getLanguages() {
    return <Language>[
      Language(0, 'English', 'en', 'US', 'assets/flags/ic_us.png'),
      Language(1, 'Khmer', 'km', 'KH', 'assets/flags/ic_km.png'),
    ];
  }

  static List<String> languages() {
    List<String> list = [];

    getLanguages().forEach((element) {
      list.add(element.languageCode);
    });

    return list;
  }

  static List<Locale> languagesLocale() {
    List<Locale> list = [];

    getLanguages().forEach((element) {
      list.add(Locale(element.languageCode, element.countryCode));
    });

    return list;
  }
}
