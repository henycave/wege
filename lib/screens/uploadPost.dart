import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

import '../model/user.dart';
import '../services/hate_checker.dart';

class UploadPost extends StatefulWidget {
  final User user;

  UploadPost({this.user});

  @override
  State<UploadPost> createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  var pickedPhoto;
  File photo;
  String text;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final _fireStore = Firestore.instance;
  var _auth = FirebaseAuth.instance;

  Future uploadFile(BuildContext context) async {
    if (photo == null && text == null) return false;
    if (photo == null && text == '') return false;
    if (photo == null && text != null) {
      if (text != '') {
        try {
          var response = await HateChecker().checkHate("$text");
         if (int.tryParse(response[1].toString()) == 0) {
            await _fireStore.collection('posts').add({
              'text': text,
              'user': widget.user.getUserDocumentReference(),
              'user_name': widget.user.getName(),
              'date': DateTime.now()
            });
            return true;
          } else {
            var user = await _fireStore
                .collection('users')
                .document(widget.user.getUserDocumentReference())
                .get();
            int strikeCount = user.data['strikes'] != null
                ? int.tryParse(user.data['strikes'].toString())
                : 0;
            if (strikeCount > 3) {
              _fireStore
                  .collection('user')
                  .document(widget.user.getUserDocumentReference())
                  .delete();
              _auth.signOut();
              Navigator.pop(context);
              return false;
            } else {
              print('Strike incremented by one');
              await _fireStore
                  .collection('users')
                  .document(widget.user.getUserDocumentReference())
                  .updateData({'strikes': FieldValue.increment(1)});
              setState(() {
                makeButtonVisible = true;
              });
              return false;
            }
            print('nope!');
            return false;
          }
        } catch (e) {
          print(e.toString());
          return false;
        }
      }
    }
    if (photo != null && text != null) {
      final fileName = basename(photo.path);
      final destination = 'posts/$fileName';

      try {
        var response = await HateChecker().checkHate("$text");
        if (int.tryParse(response[1].toString()) == 0) {
          final ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child(destination);
          final StorageUploadTask uploadTask = ref.putFile(photo);
          final snapShot = await uploadTask.onComplete;
          final urlDownload = await snapShot.ref.getDownloadURL();
          print('Download link:$urlDownload');
          await _fireStore.collection('posts').add({
            'text': text,
            'post_link': urlDownload,
            'user': widget.user.getUserDocumentReference(),
            'user_name': widget.user.getName(),
            'date': DateTime.now()
          });
          return true;
        } else {
          var user = await _fireStore
              .collection('users')
              .document(widget.user.getUserDocumentReference())
              .get();
          int strikeCount = user.data['strikes'] != null
              ? int.tryParse(user.data['strikes'])
              : 0;
          if (strikeCount > 3) {
            _fireStore
                .collection('user')
                .document(widget.user.getUserDocumentReference())
                .delete();
            _auth.signOut();
            Navigator.pop(context);
            return false;
          } else {
            // print('Strike incremented by one');
            await _fireStore
                .collection('users')
                .document(widget.user.getUserDocumentReference())
                .updateData({'strikes': FieldValue.increment(1)});
            setState(() {
              makeButtonVisible = true;
            });
            return false;
          }
          print('nope!');
          return false;
        }
      } catch (e) {
        print('error occured');
        return false;
      }
    } else if (photo != null && text == null) {
      final fileName = basename(photo.path);
      final destination = 'posts/$fileName';

      try {
        final ref =
            firebase_storage.FirebaseStorage.instance.ref().child(destination);
        final StorageUploadTask uploadTask = ref.putFile(photo);
        final snapShot = await uploadTask.onComplete;
        final urlDownload = await snapShot.ref.getDownloadURL();
        print('Download link:$urlDownload');
        await _fireStore.collection('posts').add({
          'text': '',
          'post_link': urlDownload,
          'user': widget.user.getUserDocumentReference(),
          'user_name': widget.user.getName(),
          'date': DateTime.now()
        });
        return true;
      } catch (e) {
        print('error occured');
      }
    }
  }

  bool makeButtonVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // CircleAvatar(
              //   child: ClipOval(
              //     child: Image(
              //       height: 50.0,
              //       width: 50.0,
              //       image: AssetImage("assets/images/pic2.jpg"),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   width: 8,
              // ),
              Text(
                widget.user.getName().toString(),
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Report',
                style: TextStyle(

                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(primary: Colors.deepPurpleAccent),
            onPressed: makeButtonVisible
                ? () {
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
                                width: 200,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 70, 10, 10),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Do you want to report!!!',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FloatingActionButton.extended(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              label: Text(
                                                'No',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            FloatingActionButton.extended(
                                              onPressed: () {
                                                _fireStore.collection('reported').add({
                                                  'text': text,
                                                  'user': widget.user.getUserDocumentReference(),
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              backgroundColor:
                                                  Colors.deepPurpleAccent,
                                              foregroundColor: Colors.white,
                                              label: Text(
                                                'Yes',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ]),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -40,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.deepPurpleAccent,
                                    radius: 35,
                                    child: Icon(
                                      Icons.report,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  )),
                            ],
                          )),
                    );
                  }
                : null,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Container(
                  // color: Colors.amber,
                  height: 150,
                  width: 400,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 22, top: 15, right: 12),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        text = value;
                      });
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: "what's on your mind ?",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    maxLength: 300,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 80,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.deepPurpleAccent),
                    //color: Colors.redAccent,
                  ),
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.camera_enhance,
                      size: 35,
                      color: Colors.deepPurpleAccent,
                    ),
                    label: const Text(
                      'Take Photo',
                      style: TextStyle(color: Colors.deepPurpleAccent),
                    ),
                    onPressed: () async {
                      pickedPhoto = await ImagePicker().getImage(
                        source: ImageSource.camera,
                      );
                      setState(() {
                        if (pickedPhoto != null) {
                          photo = File(pickedPhoto.path);
                        } else {
                          print('No image selected.');
                        }
                      });
                      //Navigator.pop(context);
                    },
                  )),
              const SizedBox(
                width: 10,
              ),
              Container(
                  height: 80,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.deepPurpleAccent),
                    //color: Colors.redAccent,
                  ),
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.photo_album,
                      size: 35,
                      color: Colors.deepPurpleAccent,
                    ),
                    label: const Text(
                      'photo',
                      style: TextStyle(color: Colors.deepPurpleAccent),
                    ),
                    onPressed: () async {
                      pickedPhoto = await ImagePicker().getImage(
                        source: ImageSource.gallery,
                      );
                      setState(() {
                        if (pickedPhoto != null) {
                          photo = File(pickedPhoto.path);
                        } else {
                          print('No image selected.');
                        }
                      });
                      //Navigator.pop(context);
                    },
                  )),
            ],
          ),
          Text(photo != null ? basename(photo.path).toString() : ''),
          SizedBox(
            height: 50,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          bool isSuccess = false;
          isSuccess = await uploadFile(context);
          print(isSuccess.toString());
          //Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => isSuccess
                ? Dialog(
                    backgroundColor: const Color(0xFFF2F2F2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Stack(
                      overflow: Overflow.visible,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                            child: Column(
                              children: [
                                Text(
                                  'Post Successfully!!!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            top: -50,
                            child: CircleAvatar(
                              backgroundColor: Colors.deepPurpleAccent,
                              radius: 40,
                              child: Icon(
                                Icons.done_sharp,
                                color: Colors.white,
                                size: 50,
                              ),
                            )),
                      ],
                    ))
                : Dialog(
                    backgroundColor: const Color(0xFFF2F2F2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Stack(
                      overflow: Overflow.visible,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                            child: Column(
                              children: [
                                Text(
                                  'Post Unsuccessfully!!!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            top: -50,
                            child: CircleAvatar(
                              backgroundColor: Colors.deepPurpleAccent,
                              radius: 40,
                              child: Icon(
                                Icons.done_sharp,
                                color: Colors.white,
                                size: 50,
                              ),
                            )),
                      ],
                    )),
          );
        },
        tooltip: 'Upload post',
        child: Icon(
          Icons.done_sharp,
        ),
      ),
    );
  }
}
