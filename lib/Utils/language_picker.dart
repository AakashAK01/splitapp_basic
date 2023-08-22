import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitwise_basic/Utils/locale_provider.dart';
import 'package:splitwise_basic/language/l10n.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final code = L10n.getCode(locale.languageCode);
    final provider = Provider.of<LocaleProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            provider.setLocale(Locale('en'));
            print(code);
          },
          child: Text("English",
              style: TextStyle(
                  color: code == "en" ? Colors.black : Colors.blueAccent)),
        ),
        SizedBox(width: 10),
        InkWell(
            onTap: () {
              provider.setLocale(Locale('ta'));
            },
            child: Text("தமிழ்",
                style: TextStyle(
                    color: code == "ta" ? Colors.black : Colors.blueAccent))),
        SizedBox(width: 10),
        InkWell(
            onTap: () {
              provider.setLocale(Locale('hi'));
            },
            child: Text("हिंदी",
                style: TextStyle(
                    color: code == "hi" ? Colors.black : Colors.blueAccent))),
      ],
    );
  }
}
