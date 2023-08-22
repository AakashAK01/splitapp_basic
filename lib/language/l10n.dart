import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('hi'),
    const Locale('ta')
  ];
  static String getCode(String code) {
    switch (code) {
      case 'hi':
        return 'hi';
      case 'ta':
        return 'ta';
      default:
        return 'en';
    }
  }
}
