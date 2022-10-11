import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../model/user.dart';

class EditProfile extends StatefulWidget {
  final User user;

  EditProfile({
    this.user,
  });

  @override
  _EditProfileState createState() => _EditProfileState();
}

var photo;

class _EditProfileState extends State<EditProfile> {
  bool isObscurePassword = true;
  bool isObscurePassword1 = true;
  var pickedPhoto;
  File photo;
  final _fireStore = Firestore.instance;
  final _auth = FirebaseAuth.instance;

  // void fi(){
  //   _auth
  //       .signInWithEmailAndPassword(email: 'you@domain.example', password: 'correcthorsebatterystaple')
  //       .then((userCredential) {
  //   userCredential.user.updateEmail('newyou@domain.example')
  //   });
  // }

  Future uploadFile() async {
    if (photo == null) return;
    final fileName = basename(photo.path);
    final destination = 'profile/$fileName';

    try {
      final ref =
          firebase_storage.FirebaseStorage.instance.ref().child(destination);
      final StorageUploadTask uploadTask = ref.putFile(photo);
      final snapShot = await uploadTask.onComplete;
      final urlDownload = await snapShot.ref.getDownloadURL();
      print('Download link:$urlDownload');
      await _fireStore
          .collection('users')
          .document(widget.user.getUserDocumentReference())
          .updateData({'profile_pic_url': urlDownload});
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.deepPurpleAccent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (fName == null &&
                  lName == null &&
                  oldPassword == null &&
                  newPassword == null) return;
              if (fName != null &&
                  fName != '' &&
                  lName != null &&
                  lName != '') {
                await _fireStore
                    .collection('users')
                    .document(widget.user.getUserDocumentReference())
                    .updateData({
                  'fName': fName,
                  'lName': lName,
                });
              }
              if (oldPassword.length >= 6 &&
                  oldPassword != '' &&
                  oldPassword != null &&
                  newPassword != '' &&
                  newPassword != null &&
                  newPassword.length >= 6) {
                await _auth
                    .signInWithEmailAndPassword(
                        email: widget.user.getUserEmail(),
                        password: oldPassword)
                    .then((userCredential) {
                  userCredential.user.updatePassword(newPassword);
                });
              }
              showDialog(
                context: context,
                builder: (context) => Dialog(
                    backgroundColor: const Color(0xFFF2F2F2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Stack(
                      overflow: Overflow.visible,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                            child: Column(
                              children: [
                                Text(
                                  'saved successfully!!!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),

                                // SizedBox(
                                //   height: 20,
                                // ),
                                // Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceEvenly,
                                //     children: [
                                //       FloatingActionButton.extended(
                                //         onPressed: () {
                                //           Navigator.of(context).pop();
                                //         },
                                //         backgroundColor: Colors.black,
                                //         foregroundColor: Colors.white,
                                //         label: Text(
                                //           'No',
                                //           style: TextStyle(fontSize: 18),
                                //         ),
                                //       ),
                                //       FloatingActionButton.extended(
                                //         onPressed: () {
                                //           Navigator.of(context).pop();
                                //         },
                                //         backgroundColor:
                                //             Colors.deepPurpleAccent,
                                //         foregroundColor: Colors.white,
                                //         label: Text(
                                //           'Yes',
                                //           style: TextStyle(fontSize: 16),
                                //         ),
                                //       ),
                                //     ]),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            top: -35,
                            child: CircleAvatar(
                              backgroundColor: Colors.deepPurpleAccent,
                              radius: 35,
                              child: Icon(
                                Icons.save_alt_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            )),
                      ],
                    )),
              );
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: StreamBuilder(
        stream: _fireStore
            .collection('users')
            .document(widget.user.getUserDocumentReference())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          var data = snapshot.data;
          return Stack(
            children: <Widget>[
              ClipPath(
                child: Container(
                  color: Colors.deepPurpleAccent,
                ),
                clipper: getClipper(),
              ),
              Container(
                padding: EdgeInsets.only(left: 15, top: 20, right: 15),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView(
                    children: <Widget>[
                      Center(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              width: 140.0,
                              height: 140.0,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.4)),
                                ],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: data['profile_pic_url'] != null
                                      ? NetworkImage(data['profile_pic_url'])
                                      : AssetImage(
                                          'assets/images/profile_dummy.jpeg'),
                                  // image: AssetImage("assets/images/ee.jpg"),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 46,
                                  width: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.white),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: ((builder) =>
                                            bottomSheet(context)),
                                      );
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: TextField(
                          onChanged: (value) {
                            fName = value;
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 5),
                            labelText: ''
                                'First Name',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: data['fName'],
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: TextField(
                          onChanged: (value) {
                            lName = value;
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 5),
                            labelText: ''
                                'Last Name',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: data['lName'],
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: TextField(
                          onChanged: (value) {
                            oldPassword = value;
                          },
                          obscureText: isObscurePassword,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye,
                                  color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  isObscurePassword = !isObscurePassword;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.only(bottom: 5),
                            labelText: 'Old Password',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: "********",
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: TextField(
                          onChanged: (value) {
                            newPassword = value;
                          },
                          obscureText: isObscurePassword1,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye,
                                  color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  isObscurePassword1 = !isObscurePassword1;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.only(bottom: 5),
                            labelText: 'New Password',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: "********",
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      //buildTextField("Phone", "+251 7457800", false),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 220,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Text(
                "choose profile photo",
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // ignore: deprecated_member_use
                  FlatButton.icon(
                      onPressed: () async {
                        pickedPhoto = await ImagePicker().getImage(
                          source: ImageSource.camera,
                        );
                        setState(() {
                          if (pickedPhoto != null) {
                            photo = File(pickedPhoto.path);
                            uploadFile();
                          } else {
                            print('No image selected.');
                          }
                        });
                        Navigator.pop(context);
                      },
                      splashColor: Colors.deepPurpleAccent,
                      icon: Icon(Icons.camera_alt),
                      label: Text("Camera")),
                  // ignore: deprecated_member_use
                  FlatButton.icon(
                      onPressed: () async {
                        pickedPhoto = await ImagePicker().getImage(
                          source: ImageSource.gallery,
                        );
                        setState(() {
                          if (pickedPhoto != null) {
                            photo = File(pickedPhoto.path);
                            uploadFile();
                          } else {
                            print('No image selected.');
                          }
                        });
                        Navigator.pop(context);
                      },
                      splashColor: Colors.deepPurpleAccent,
                      icon: Icon(Icons.image),
                      label: Text("Gallery")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String fName;
  String lName;
  String oldPassword;
  String newPassword;

// Widget buildTextField(
//     String labelText, String placeholder, bool isPasswordTextFiled, String text) {
//   return Padding(
//     padding: EdgeInsets.only(bottom: 30),
//     child: TextField(
//       onChanged: (value){
//         text = value;
//         print(name);
//       },
//       obscureText: isPasswordTextFiled ? isObscurePassword : false,
//       decoration: InputDecoration(
//         suffixIcon: isPasswordTextFiled
//             ? IconButton(
//                 icon: Icon(Icons.remove_red_eye, color: Colors.grey),
//                 onPressed: () {
//                   setState(() {
//                     isObscurePassword = !isObscurePassword;
//                   });
//                 },
//               )
//             : null,
//         contentPadding: EdgeInsets.only(bottom: 5),
//         labelText: labelText,
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         hintText: placeholder,
//         hintStyle: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey,
//         ),
//       ),
//     ),
//   );
// }
}

// ignore: camel_case_types
class getClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    double height = size.height;
    double width = size.width;
    //path.lineTo(0.0, size.height / 1);
    // path.lineTo(size.width + 125, 0.0);
    path.lineTo(0.0, size.height / 5);
    path.quadraticBezierTo(width / 2, height / 9, width, height / 3);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
