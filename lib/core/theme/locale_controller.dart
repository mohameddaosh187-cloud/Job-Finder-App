import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  static const String _localeKey = 'app_locale';

  static const String englishCode = 'en';
  static const String arabicCode = 'ar';

  Locale _locale = const Locale(englishCode);

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == arabicCode;

  bool get isEnglish => _locale.languageCode == englishCode;

  /// Load the saved language from SharedPreferences.
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_localeKey);

    final languageCode =
        savedLanguage == arabicCode || savedLanguage == englishCode
            ? savedLanguage!
            : englishCode;

    final newLocale = Locale(languageCode);

    if (_locale.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      notifyListeners();
    }

    // Save the default language if no valid value was stored.
    if (savedLanguage != languageCode) {
      await prefs.setString(_localeKey, languageCode);
    }
  }

  /// Change the app language and persist the selection.
  Future<void> setLocale(Locale locale) async {
    final languageCode = locale.languageCode;

    if (languageCode != arabicCode && languageCode != englishCode) {
      return;
    }

    if (_locale.languageCode == languageCode) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_localeKey, languageCode);

    _locale = Locale(languageCode);

    notifyListeners();
  }
}
