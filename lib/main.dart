import 'package:easy_localization/easy_localization.dart';
import 'package:wege/screens/home_screen.dart';
import 'package:wege/translations/codegen_loader.g.dart';
import 'package:flutter/material.dart';
import 'package:wege/screens/welcome_screen.dart';
import 'package:wege/screens/login_screen.dart';
import 'package:wege/screens/registration_screen.dart';
import 'package:wege/screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
    path: 'assets/translations',
    supportedLocales: [
      Locale('en'),
      Locale('am'),
    ],
    fallbackLocale: Locale('en'),
    assetLoader: CodegenLoader(),
    child: Weg(),
  ));
}

class Weg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}
