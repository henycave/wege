import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wege/components/rounded_button.dart';
import 'package:wege/constants.dart';
import 'package:wege/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../model/user.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wege/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

import 'home.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  final _fireStore = Firestore.instance;
  String userDocumentReference;
  String name;
  User user;
  FirebaseUser loggedInUser;

  Future<void> getCurrentUser(String loggedInUserEmail) async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        var document = await _fireStore.collection('users').where('email',isEqualTo:loggedInUserEmail).getDocuments();
        if(document.documents.isNotEmpty){
          document.documents.forEach((element) {
            userDocumentReference = element.documentID;
            name = element.data['fName'];
          });
          print(name);
          print(loggedInUserEmail);
          print(userDocumentReference);
          this.user = User(name: name, userEmail: loggedInUserEmail, userDocumentReference: userDocumentReference);
        }
      }
    } catch (e) {
      print(e);
    }
  }


  String email;
  String password;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String errorText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('assets/images/jebena2.jpeg'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: KTextFiledDecoration.copyWith(
                      hintText: LocaleKeys.enter_email.tr())),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: KTextFiledDecoration.copyWith(
                    hintText: LocaleKeys.enter_password.tr()),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                text: LocaleKeys.log_in.tr(),
                color: Colors.cyan,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final loggedInUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (loggedInUser != null) {
                      await getCurrentUser(email);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Home(
                                    user: user,
                                  )));
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                    print(e);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
