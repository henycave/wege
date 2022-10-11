import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wege/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wege/screens/individual_chat_screen.dart';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wege/translations/locale_keys.g.dart';

import '../model/user.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  final User user;

  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) loggedInUser = user;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        //backgroundColor: Colors.deepPurpleAccent,
        body: Container(
          // color: Colors.blueGrey,
          padding: EdgeInsets.only(top: 35, left: 20, right: 20, bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    color: Colors.deepPurpleAccent,
                    onPressed: () {
                      Navigator.pushNamed(context, ChatScreen.id);
                    },
                    child: Text(
                      LocaleKeys.buna_chat.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: _fireStore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      );
                    }
                    final users = snapshot.data.documents;
                    List<Widget> friends = [];
                    for (var user in users) {
                      final fName = user.data['fName'];
                      final lName = user.data['lName'];
                      final email = user.data['email'];
                      bool isSelf = false;
                      if (email == widget.user.getUserEmail()) {
                        isSelf = true;
                      }
                      final userTile = Card(
                        elevation: 5,
                      child:ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                        tileColor: Colors.white.withOpacity(1),

                        onTap: () {
                          print(email);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => IndividualChatScreen(
                                        tapedFriendEmail: email,
                                        loggedInUserEmail:
                                            widget.user.getUserEmail(),
                                      )));
                        },
                        leading: Icon(
                          Icons.person_pin,
                          color: Colors.deepPurpleAccent,
                        ),
                        title: Text(
                          isSelf ? 'Saved Messages' : fName + ' ' + lName,
                          style: TextStyle(color: Colors.black),
                        ),
                        // subtitle: Text(
                        //   email,
                        //   style: TextStyle(color: Colors.white),
                        // ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_sharp,
                          color: Colors.grey,
                          size: 15,
                        ),
                      ),
                      );
                      friends.add(userTile);
                      friends.add(SizedBox(
                        height: 5,
                      ));

                    }
                    return Expanded(
                        child: ListView(
                      children: friends,
                    ));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
