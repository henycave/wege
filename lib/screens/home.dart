import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wege/model/user.dart';
import 'package:wege/screens/home_screen.dart';
import 'package:wege/screens/search.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';
import 'profile_page.dart';

class Home extends StatefulWidget {
  final User user;
  Home({this.user});

  @override
  _HomeState createState() => _HomeState();
}

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
  }

  // Future<void> getCurrentUser() async {
  //   try {
  //     final user = await _auth.currentUser();
  //     if (user != null) {
  //       loggedInUser = user;
  //       var document = await _fireStore.collection('users').where('email',isEqualTo: widget.loggedInUserEmail).getDocuments();
  //       if(document.documents.isNotEmpty){
  //         document.documents.forEach((element) {
  //           userDocumentReference = element.documentID;
  //           name = element.data['fName'];
  //         });
  //         print(name);
  //         print(widget.loggedInUserEmail);
  //         print(userDocumentReference);
  //         this.user = User(name: name, userEmail: widget.loggedInUserEmail, userDocumentReference: userDocumentReference);
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  int _selectedIndex = 0;
  List<Widget> _wdgetOptions() =>
      [
        HomePage(user: widget.user,),
        Search(),
        HomeScreen(user: widget.user,),
        ProfilePage(
          isSelf: true,
          user: widget.user,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //backgroundColor: const Color(0xFFEDF0F6),
      body: Center(
        child: _wdgetOptions.call().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.white,
        //backgroundColor: const Color(0xFFEDF0F6),
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(
              Icons.home,
              size: 25,
            ),
            title: const Text(
              'home',
            ),
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.grey.shade600,
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.search,
              size: 25,
            ),
            title: const Text(
              'Search',
            ),
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.grey.shade600,
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.message_outlined,
              size: 25,
            ),
            title: const Text(
              'chat',
            ),
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.grey.shade600,
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.person,
              size: 25,
            ),
            title: const Text(
              'profile',
            ),
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.grey.shade600,
          ),

        ],
      ),
    );
  }
}
