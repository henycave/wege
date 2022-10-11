import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wege/components/rounded_button.dart';
import 'package:wege/constants.dart';
import 'package:wege/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wege/translations/locale_keys.g.dart';

import 'home.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  String fName;
  String lName;
  String age;
  String phoneNumber;
  String gender;

  FirebaseUser loggedInUser;
  String userDocumentReference;
  String name;
  User user;

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


  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  bool showSpinner = false;
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
                onChanged: (value) {
                  fName = value;
                },
                decoration: KTextFiledDecoration.copyWith(
                    hintText: LocaleKeys.enter_f_name.tr()),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  lName = value;
                },
                decoration: KTextFiledDecoration.copyWith(
                    hintText: LocaleKeys.enter_l_name.tr()),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  age = value;
                },
                decoration: KTextFiledDecoration.copyWith(
                    hintText: LocaleKeys.enter_age.tr()),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  gender = value;
                },
                decoration: KTextFiledDecoration.copyWith(
                    hintText: 'Gender'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(

                  keyboardType: TextInputType.emailAddress,

                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: KTextFiledDecoration.copyWith(
                      hintText: LocaleKeys.enter_email.tr())),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
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
                text: LocaleKeys.register,
                color: Colors.deepPurpleAccent,
                onPressed: () async {
                  if (fName != '' ||
                      lName != '' ||
                      age != '' ||
                      email != '' ||
                      password != '') {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        _fireStore.collection('users').add({
                          'fName': fName,
                          'lName': lName,
                          'age': age,
                          'email': email,
                          'gender': gender,
                          'searchKey':fName[0]
                        });
                        await getCurrentUser(email);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Home(
                                      user: user,
                                    )));
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    } catch (e) {
                      setState(() {
                        showSpinner = false;
                      });
                      print(e);
                    }
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
