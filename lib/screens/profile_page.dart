import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wege/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wege/translations/locale_keys.g.dart';

import '../model/post_model.dart';
import '../model/user.dart';
import 'EditProfile.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final bool isSelf;

  ProfilePage({this.user, this.isSelf});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fireStore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  String fName;
  String lName;
  String age;
  String gender;
  String email;
  String phone;
  String profileImage;
  bool isMale = false;
  int _value = 1;
  List<String> networkImages = [];

  String postUrl;
  String text;
  String userReference;
  String date;
  String userName;

  String postReference;
  int like = 0;
  String reference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        automaticallyImplyLeading: false,
        title: Text(
          "Weg",
          style: TextStyle(
              fontFamily: 'Billabong',
              fontSize: 33,
              color: Colors.white),
        ),
      ),
      //backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('users')
            .where('email', isEqualTo: widget.user.getUserEmail())
            .snapshots(),
        builder: (context, snapshot1) {
          if (!snapshot1.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final users = snapshot1.data.documents;
          for (var user in users) {
            fName = user.data['fName'];
            lName = user.data['lName'];
            email = user.data['email'];
            age = user.data['age'].toString();
            gender = user.data['gender'];
            phone = user.data['phone'];
            profileImage = user.data['profile_pic_url'];
            reference = user.documentID;
            widget.user.userDocumentReference = reference;
          }
          if (gender == 'Male') {
            isMale = true;
          }
          print(widget.user.getUserDocumentReference());
          return StreamBuilder(
            stream: _fireStore
                .collection('posts')
                .where('user',
                    isEqualTo: widget.user.getUserDocumentReference())
                .snapshots(),
            builder: (context, snapshot2) {
              if (!snapshot2.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                );
              }
              final posts = snapshot2.data.documents;
              List<Post> postsList = [];
              if (posts.isEmpty) {
                print('empty');
              }
              for (var post in posts) {
                print(post.data);
                userReference = post.data['user'];
                text = post.data['text'];
                postUrl = post.data['post_link'];
                //userName = post.data['user_name'];
                // like = post.data['like'] != '' && post.data['like'] != null
                //     ? int.tryParse(post.data['like'])
                //     : 0;
                like = post.data['like']!=null?post.data['like']:0;
                postReference = post.documentID.toString();

                date = DateFormat.yMMMd()
                    .add_jm()
                    .format(post.data['date'].toDate())
                    .toString();
                if (postUrl != null && postUrl != '') {
                  postsList.add(Post(
                    imageUrl: postUrl,
                    authorName: userName,
                    timeAgo: date,
                    text: text,
                    like: like,
                    authorReference: userReference,
                    postReference: postReference,
                  ));
                }
              }
              // print(postsList[1].authorName);
              return SafeArea(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    widget.isSelf
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 15, left: 25),
                                child: DropdownButton(
                                    borderRadius: BorderRadius.circular(10),
                                    iconEnabledColor: Colors.amber,
                                    focusColor: Colors.blue,
                                    dropdownColor: Colors.white,
                                    value: _value,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text(
                                          "English",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        value: 1,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          "አማርኛ",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        value: 2,
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        context.setLocale(value == 1
                                            ? Locale('en')
                                            : Locale('am'));
                                        _value = value;
                                      });
                                    }),
                                /*child: Row(
                            children: [
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration:
                                      BoxDecoration(color: Colors.lightGreen),
                                  child: Text(
                                    'English',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                onTap: () {
                                  context.setLocale(Locale('en'));
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration:
                                      BoxDecoration(color: Colors.lightGreen),
                                  child: Text(
                                    'አማርኛ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                onTap: () {
                                  context.setLocale(Locale('am'));
                                },
                              ),
                            ],
                          ),*/
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 25, top: 15),
                                child: FlatButton(
                                  onPressed: () {
                                    _auth.signOut();
                                    Navigator.pushNamed(
                                        context, WelcomeScreen.id);
                                  },
                                  child: Text(
                                    LocaleKeys.log_out.tr(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: widget.isSelf
                          ? () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile(
                                              user: widget.user,
                                            )));
                              });
                            }
                          : null,
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: profileImage != null
                            ? NetworkImage(profileImage)
                            : AssetImage('assets/images/profile_dummy.jpeg'),
                      ),
                    ),
                    Text(
                      fName + ' ' + lName,
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        color: Colors.grey,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w100,
                        //letterSpacing: 2.5,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 150,
                      child: Divider(
                        color: Colors.teal.shade100,
                      ),
                    ),
                    widget.isSelf
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 37,
                                width: 140,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.deepPurpleAccent),
                                  // color: Colors.deepPurpleAccent
                                ),
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 10,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  label: const Text(
                                    'Add Story',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.deepPurpleAccent),
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 37,
                                width: 130,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.deepPurpleAccent),
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Edit profile',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditProfile(
                                                    user: widget.user,
                                                  )));
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    postsList.isNotEmpty
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 6.0,
                                children:
                                    List.generate(postsList.length, (index) {
                                  return Center(
                                    child: Container(
                                      //margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        //borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            // color: Colors.black45,
                                            offset: Offset(0, 0.5),
                                            blurRadius: 1.0,
                                          ),
                                        ],
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              postsList[index].imageUrl),
                                          //image: AssetImage("assets/images/ji.jpg"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          )
                        : Container()
                    /*Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.wc_sharp,
                        color: Colors.teal,
                      ),
                      title: Text(
                        gender,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.teal.shade900,
                          fontFamily: 'Source Sans Pro',
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.timer_rounded,
                        color: Colors.teal,
                      ),
                      title: Text(
                        age,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.teal.shade900,
                          fontFamily: 'Source Sans Pro',
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.email,
                        color: Colors.teal,
                      ),
                      title: Text(
                        email,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.teal.shade900,
                          fontFamily: 'Source Sans Pro',
                        ),
                      ),
                    ),
                  ),*/
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
