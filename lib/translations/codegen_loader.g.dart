// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader {
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String, dynamic> en = {
    "log_in": "Log In",
    "register": "Register",
    "enter_email": "Enter your email",
    "enter_password": "Enter your password",
    "enter_f_name": "Enter your First Name",
    "enter_l_name": "Enter your Last Name",
    "enter_age": "Enter your Age",
    "weg": "Weg",
    "buna_chat": "Buna Chat",
    "send": "Send",
    "type_message_here": "Type your message here",
    "log_out": "Log Out",
    "profile": "Profile",
    "see_profile": "See Profile",
    "enter_gender": "Enter your Gender",
  };
  static const Map<String, dynamic> am = {
    "log_in": "ግባ",
    "register": "ይመዝገቡ",
    "enter_email": "ኢሜልዎን ያስገቡ",
    "enter_password": "የይለፍ ቃልዎን ያስገቡ",
    "enter_f_name": "የእርስዎን ስም ያስገቡ",
    "enter_l_name": "የአባትዎን ስም ያስገቡ",
    "enter_age": "እድሜዎን ያስገቡ",
    "weg": " ወግ",
    "buna_chat": "የቡና ወግ",
    "send": "ላክ",
    "type_message_here": "መልክትዎን እዚህ ላይ ያስፍሩ",
    "log_out": "ውጣ",
    "profile": "መገለጫ",
    "see_profile": "መገለጫ ይመልከቱ",
    "enter_gender": "ፆታዎን ያስገቡ",
  };
  static const Map<String, Map<String, dynamic>> mapLocales = {
    "en": en,
    "am": am
  };
}
