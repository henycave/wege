import 'package:wege/screens/home_screen.dart';
import 'package:wege/screens/login_screen.dart';
import 'package:wege/screens/registration_screen.dart';
import 'package:wege/translations/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:wege/components/rounded_button.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);

    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: animation.value,
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('assets/images/jebena2.jpeg'),
                      height: 130.0,
                    ),
                  ),
                ),
                TypewriterAnimatedTextKit(
                  speed: Duration(milliseconds: 700),
                  repeatForever: false,
                  text: [LocaleKeys.weg.tr()],
                  textStyle: TextStyle(
                    fontFamily: 'Billabong',
                    color: Colors.black,
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              // Colors.lightBlueAccent
              color: Colors.cyan,
              text: LocaleKeys.log_in.tr(),
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
                // Navigator.pushNamed(context, HomeScreen.id);
              },
            ),
            RoundedButton(
              // Colors.blueAccent
              color: Colors.deepPurpleAccent,
              text: LocaleKeys.register.tr(),
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            )
          ],
        ),
      ),
    );
  }
}
