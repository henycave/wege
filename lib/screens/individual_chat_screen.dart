import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wege/components/message_bubble.dart';
import 'package:wege/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:wege/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wege/translations/locale_keys.g.dart';

import '../model/user.dart';

class IndividualChatScreen extends StatefulWidget {
  static const String id = 'individual_chat_screen';
  final String loggedInUserEmail;
  final String tapedFriendEmail;

  IndividualChatScreen({this.tapedFriendEmail, this.loggedInUserEmail});

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class _IndividualChatScreenState extends State<IndividualChatScreen> {
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
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          isSelf: false,
                              user: User(userEmail: widget.tapedFriendEmail),
                            )));
              },
              child: Text(
                LocaleKeys.see_profile.tr(),
                style: TextStyle(color: Colors.white, fontSize: 18),
              ))
        ],
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            IndividualMessageStream(
              receiver: widget.tapedFriendEmail,
              sender: widget.loggedInUserEmail,
            ),
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
                      _fireStore.collection('private_messages').add({
                        'message': message,
                        'sender': widget.loggedInUserEmail,
                        'time': DateTime.now().toString(),
                        'receiver': widget.tapedFriendEmail,
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

class IndividualMessageStream extends StatelessWidget {
  final String receiver;
  final String sender;

  IndividualMessageStream({this.receiver, this.sender});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('private_messages')
          .where('sender', whereIn: [sender, receiver]).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        return StreamBuilder(
            stream: _fireStore
                .collection('private_messages')
                .where('receiver', whereIn: [sender, receiver]).snapshots(),
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
                final messageText = message.data['message'];
                final messageSender = message.data['sender'];
                final messageReceiver = message.data['receiver'];
                final messageSentTime = message.data['time'];
                if ((sender == messageSender && receiver == messageReceiver) ||
                    (sender == messageReceiver && receiver == messageSender)) {
                  final messageBubble = MessageBubble(
                    sender: messageSender,
                    text: messageText,
                    time: messageSentTime,
                    isMe: sender == messageSender,
                  );
                  messageBubbles.add(messageBubble);
                  messageBubbles.sort((a, b) =>
                      DateTime.parse(b.time).compareTo(DateTime.parse(a.time)));
                }
              }
              return Expanded(
                child: ListView(
                  reverse: true,
                  children: messageBubbles,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                ),
              );
            });
      },
    );
  }
}
