import 'package:flutter/material.dart';
import 'package:wege/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wege/components/message_bubble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wege/translations/locale_keys.g.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String message;
  final messageTextController = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(

        //elevation: 3,
        leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        // actions: <Widget>[
        //   IconButton(
        //       icon: Icon(Icons.close),
        //       onPressed: () {
        //         _auth.signOut();
        //         Navigator.pop(context);
        //       }),
        // ],
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                          hintText: LocaleKeys.type_message_here.tr()),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'text': message,
                        'sender': loggedInUser.email,
                        'time': DateTime.now().toString(),
                      });
                    },
                    child: Text(
                      LocaleKeys.send.tr(),
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          final messageSentTime = message.data['time'];
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            time: messageSentTime,
            isMe: loggedInUser.email == messageSender,
          );
          messageBubbles.add(messageBubble);
          messageBubbles.sort((a, b) =>
              DateTime.parse(b.time).compareTo(DateTime.parse(a.time)));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageBubbles,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          ),
        );
      },
    );
  }
}
