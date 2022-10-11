import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wege/screens/view_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/post_model.dart';
import 'package:intl/intl.dart';
import '../model/user.dart';
import 'search.dart';
import 'uploadPost.dart';
import 'viewPostScreen.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future getImage(reference) async {
    String url;
    var document =
        await _fireStore.collection('users').document(reference).get();
    url = document.data['profile_pic_url'];
    return url;
  }

  Future getCommentCount(reference) async {
    int commentCount;
    await _fireStore
        .collection('posts')
        .document(reference)
        .collection('comments')
        .getDocuments()
        .then((value) => commentCount = value.documents.length);
    return commentCount;
  }

  String posterProfilePic;

  Widget _buildPost(Post post) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Column(
        children: [
          ListTile(
            leading: Container(
                width: 50.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: FutureBuilder(
                  future: getImage(post.authorReference),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      posterProfilePic = snapshot.data.toString();
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
            title: Text(
              post.authorName != null ? post.authorName : 'null',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle:
                Text(post.timeAgo != null ? post.timeAgo.toString() : 'null'),
            trailing: IconButton(
              icon: Icon(Icons.more_horiz),
              color: Colors.black,
              onPressed: () => print('More'),
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 25, bottom: 1),
                child: Text(
                  post.text != null ? post.text : 'Null',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.start,
                ),
              )),
          post.imageUrl != null
              ? InkWell(
                  onDoubleTap: () async{
                    var documents = await _fireStore
                        .collection('liked_posts')
                        .where('user_ref',
                        isEqualTo:
                        widget.user.userDocumentReference)
                        .getDocuments();
                    var isEmpty = documents.documents.isEmpty;
                    print(isEmpty);
                    if (isEmpty) {
                      await _fireStore.collection('liked_posts').add({
                        'post_ref': post.postReference,
                        'user_ref':
                        widget.user.getUserDocumentReference()
                      });
                      await _fireStore
                          .collection('posts')
                          .document(post.postReference)
                          .updateData({
                        'like': FieldValue.increment(1),
                      });

                      print('liked');
                    } else {
                      await _fireStore
                          .collection('posts')
                          .document(post.postReference)
                          .updateData({
                        'like': FieldValue.increment(-1),
                      });
                      await _fireStore
                          .collection('liked_posts')
                          .document(documents.documents[0].documentID)
                          .delete();

                      print('disLiked');
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewPostScreen(
                          profilePic: posterProfilePic,
                          post: post,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  child: Container(
                      margin: EdgeInsets.all(0.0),
                      width: double.infinity,
                      height: 370.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white,
                            // color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 4.0,
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(post.imageUrl),
                          //image: AssetImage("assets/images/ji.jpg"),
                          fit: BoxFit.fitWidth,
                        ),
                      )),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.favorite_border,
                          ),
                          iconSize: 20.0,
                          onPressed: () async {
                            var documents = await _fireStore
                                .collection('liked_posts')
                                .where('user_ref',
                                    isEqualTo:
                                        widget.user.userDocumentReference).where('post_ref',isEqualTo: post.postReference)
                                .getDocuments();
                            var isEmpty = documents.documents.isEmpty;
                            print(isEmpty);
                            if (isEmpty) {
                              await _fireStore.collection('liked_posts').add({
                                'post_ref': post.postReference,
                                'user_ref':
                                    widget.user.getUserDocumentReference()
                              });
                              await _fireStore
                                  .collection('posts')
                                  .document(post.postReference)
                                  .updateData({
                                'like': FieldValue.increment(1),
                              });
                              print('liked');
                            } else if(!isEmpty) {
                              await _fireStore
                                  .collection('posts')
                                  .document(post.postReference)
                                  .updateData({
                                'like': FieldValue.increment(-1),
                              });
                              await _fireStore
                                  .collection('liked_posts')
                                  .document(documents.documents[0].documentID)
                                  .delete();
                              print('disLiked');
                            }
                          },
                        ),
                        Text(
                          post.like.toString(),
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
                          icon: const Icon(Icons.chat),
                          iconSize: 20.0,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewPostScreen(
                                  profilePic: posterProfilePic,
                                  post: post,
                                  user: widget.user,
                                ),
                              ),
                            );
                          },
                        ),
                        FutureBuilder(
                          future: getCommentCount(post.postReference),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              posterProfilePic = snapshot.data.toString();
                              return Text(
                                snapshot.data.toString(),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600),
                              );
                            } else {
                              return CircleAvatar(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.lightBlueAccent,
                                ),
                              );
                            }
                          },
                        ),
                        // const Text(
                        //   '350',
                        //   style: TextStyle(
                        //     fontSize: 14.0,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
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
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewPostScreen(
                          profilePic: posterProfilePic,
                          post: post,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  child: Text('View all comments',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                ),
              )),
        ],
      ),
    );


  }

  final _fireStore = Firestore.instance;
  String postUrl;
  String text;
  String userReference;
  String date;
  String userName;

  String postReference;
  int like = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Weg",
          style: TextStyle(
              fontFamily: 'Billabong',
              fontSize: 33,
              color: Colors.deepPurpleAccent),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            iconSize: 30.0,
            color: Colors.deepPurpleAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Search()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            iconSize: 30.0,
            color: Colors.deepPurpleAccent,
            onPressed: () => print('notification Messages'),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      //backgroundColor: const Color(0xFFEDF0F6),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('posts')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          List<Post> postsList = [];
          final posts = snapshot.data.documents;
          for (var post in posts) {
            //  int commentCount;
            // post.reference.collection('comments').getDocuments().then((value) => commentCount = value.documents.length);
            userReference = post.data['user'];
            text = post.data['text'];
            postUrl = post.data['post_link'];
            userName = post.data['user_name'];

            // like = post.data['like'] != '' && post.data['like'] != null
            //     ? int.tryParse(post.data['like'])
            //     : 0;
            like = post.data['like'] != null ? post.data['like'] : 0;
            postReference = post.documentID.toString();

            date = DateFormat.yMMMd()
                .add_jm()
                .format(post.data['date'].toDate())
                .toString();
            postsList.add(Post(
              imageUrl: postUrl,
              //commentCount: commentCount,
              authorName: userName,
              timeAgo: date,
              text: text,
              like: like,
              authorReference: userReference,
              postReference: postReference,
            ));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,

            //physics: ClampingScrollPhysics(),
            child: Column(
              children: <Widget>[
                //story
                Container(
                  width: double.infinity,
                  height: 100.0,
                  // color: Colors.amber,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stories.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return SizedBox(width: 10.0);
                        }
                        return InkWell(
                          onDoubleTap: () => print('stories'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewStory(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4.0),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  // color: Colors.black45,
                                  offset: Offset(0, 0.5),
                                  blurRadius: 1.0,
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage(stories[index - 1]),
                                //image: AssetImage("assets/images/ji.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }),
                ),
                Container(
                  width: double.infinity,

                  child: ListView.builder(
                    shrinkWrap: true,
                    //physics: ClampingScrollPhysics(),
                    itemCount: postsList.length,
                    //physics: AlwaysScrollableScrollPhysics(),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return _buildPost(postsList[index]);
                    },
                  ),
                ),

                // _buildPost(0),
                // _buildPost(1),
                // _buildPost(3),
                // _buildPost(4),
                // _buildPost(5),
                // _buildPost(6),

              ],

            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadPost(
                      user: widget.user,
                    )),
          );
        },
        tooltip: 'UploadNewPost',
        child: Icon(Icons.add),
      ),
    );
  }
}
