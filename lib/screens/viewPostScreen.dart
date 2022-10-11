import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/comment.dart';
import '../model/post_model.dart';
import '../model/user.dart';

class ViewPostScreen extends StatefulWidget {
  final Post post;
  final profilePic;
  final User user;

  const ViewPostScreen({this.post, this.profilePic, this.user});

  @override
  _ViewPostScreenState createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  var _controller = TextEditingController();

  Widget _buildComment(Comment comment) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: ListTile(
        // leading: Container(
        //   width: 50.0,
        //   height: 50.0,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     boxShadow: [
        //       // BoxShadow(
        //       //   color: Colors.black45,
        //       //   offset: Offset(0, 2),
        //       //   blurRadius: 6.0,
        //       // ),
        //     ],
        //   ),
        //   // child: FutureBuilder(
        //   //   future: getImage(comment.authorRef),
        //   //   builder: (BuildContext context, snapshot) {
        //   //     print(comment.authorRef);
        //   //     if (snapshot.hasData) {
        //   //       print('in hear');
        //   //       return CircleAvatar(
        //   //           child: ClipOval(
        //   //             child: Image(
        //   //               height: 50.0,
        //   //               width: 50.0,
        //   //               //image: AssetImage(posts[index].authorImageUrl),
        //   //               image: NetworkImage(snapshot.data.toString()),
        //   //               fit: BoxFit.cover,
        //   //             ),
        //   //           ));
        //   //     } else {
        //   //       print('nope');
        //   //       return CircleAvatar(
        //   //         child: CircularProgressIndicator(
        //   //           backgroundColor: Colors.lightBlueAccent,
        //   //         ),
        //   //       );
        //   //     }
        //   //   },
        //   // )
        // ),
        title: Text(
          comment.authorName != null ? comment.authorName : '',
          // comments[index].authorName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          comment.text != null ? comment.text : '',
        ),
        //Text(comments[index].text),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite_border,
          ),
          color: Colors.grey,
          onPressed: () => print('Like comment'),
        ),
      ),
    );
  }

  String userProfilePic;
  final _fireStore = Firestore.instance;

  Future getImage(reference) async {
    print('hi $reference');
    String url;
    var document =
        await _fireStore.collection('users').document(reference).get();
    url = document.data['profile_pic_url'];
    print('url $url');
    return url;
  }

  String commenterName;
  String commentText;
  String commenterUserReference;
  List<Comment> commentsList = [];
  int numberOfComments;

  String nowComment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
          stream: _fireStore
              .collection('posts')
              .document(widget.post.postReference)
              .collection('comments')
              .orderBy('date')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              );
            }
            List<Widget> widgetCommentList = [];
            final comments = snapshot.data.documents;
            numberOfComments = comments.length;
            for (var comment in comments) {
              commenterName = comment.data['commenterName'];
              commentText = comment.data['text'];
              commenterUserReference = comment.data['commenterRef'];
              // commentsList.add(Comment(
              //   authorName: commenterName,
              //   authorRef: commenterUserReference,
              //   text: commentText,
              // ));

              widgetCommentList.add(_buildComment(Comment(
                authorName: commenterName,
                authorRef: commenterUserReference,
                text: commentText,
              )));
            }
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 25.0),
                    width: double.infinity,
                    height: widget.post.imageUrl != null ? 605.0 : 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    iconSize: 25.0,
                                    color: Colors.black,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: ListTile(
                                        leading: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black45,
                                                offset: Offset(0, 2),
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            child: ClipOval(
                                              child: Image(
                                                height: 50.0,
                                                width: 50.0,
                                                image: NetworkImage(
                                                    widget.profilePic),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          widget.post.authorName != null
                                              ? widget.post.authorName
                                              : 'null',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                            widget.post.timeAgo != null
                                                ? widget.post.timeAgo
                                                : 'null'),
                                        trailing: IconButton(
                                          icon: Icon(Icons.more_horiz),
                                          color: Colors.black,
                                          onPressed: () => print('More'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 25),
                                    child: Text(
                                      widget.post.text != null
                                          ? widget.post.text
                                          : 'null',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.start,
                                    ),
                                  )),
                              widget.post.imageUrl != null
                                  ? InkWell(
                                      onDoubleTap: () => print('Like post'),
                                      child: Container(
                                        margin: EdgeInsets.all(2.0),
                                        width: double.infinity,
                                        height: 400.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                widget.post.imageUrl),
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(Icons.favorite_border),
                                              iconSize: 20.0,
                                              onPressed: () =>
                                                  print('Like post'),
                                            ),
                                            Text(
                                              widget.post.like.toString(),
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 20.0),
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(Icons.chat),
                                              iconSize: 20.0,
                                              onPressed: () {
                                                print('Chat');
                                              },
                                            ),
                                            Text(
                                              numberOfComments != null
                                                  ? '$numberOfComments'
                                                  : '',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.bookmark_border),
                                      iconSize: 20.0,
                                      onPressed: () => print('Save post'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 2,
                    endIndent: 5,
                  ),
                  //SizedBox(height: 5.0),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                      ),
                    ),
                    child: Column(
                      children: widgetCommentList,
                    ),
                  )
                ],
              ),
            );
          }),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, -2),
                blurRadius: 3.0,
              ),
            ],
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                nowComment = value;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.all(20.0),
                hintText: 'Add a comment',
                prefixIcon: Container(
                    margin: EdgeInsets.all(4.0),
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: FutureBuilder(
                      future: getImage(widget.user.getUserDocumentReference()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          userProfilePic = snapshot.data.toString();
                          return CircleAvatar(
                              child: ClipOval(
                            child: Image(
                              height: 50.0,
                              width: 50.0,
                              //image: AssetImage(posts[index].authorImageUrl),
                              image: NetworkImage(snapshot.data.toString()),
                              fit: BoxFit.cover,
                            ),
                          ));
                        } else {
                          return CircleAvatar(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlueAccent,
                            ),
                          );
                        }
                      },
                    )),
                suffixIcon: Container(
                  margin: EdgeInsets.only(right: 4.0),
                  width: 50.0,
                  height: 10,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Colors.deepPurple,
                    onPressed: () async {
                      await _fireStore
                          .collection('posts')
                          .document(widget.post.postReference)
                          .collection('comments')
                          .add({
                        'commenterName': widget.user.getName(),
                        'commenterRef': widget.user.getUserDocumentReference(),
                        'text': nowComment,
                        'date': DateTime.now(),
                      });
                      setState(() {
                        _controller.clear();
                      });
                    },
                    child: Icon(
                      Icons.send,
                      size: 25.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
