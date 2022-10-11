import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wege/services/search_service.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';
import 'profile_page.dart';

class Search extends StatefulWidget {
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var queryResultSet = [];
  var tempSearchStore = [];

  initialSearch(value) {
    print(value);

    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          queryResultSet.add(docs.documents[i].data);
          setState(() {
            tempSearchStore.add(queryResultSet[i]);
          });
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['fName'].toLowerCase().contains(value.toLowerCase()) ==  true) {
          if (element['fName'].toLowerCase().indexOf(value.toLowerCase()) ==0) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        }

      });
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {});
    }
  }

  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1.5,
          automaticallyImplyLeading: false,
          //backgroundColor: const Color(0xFFEDF0F6),
          backgroundColor: Colors.white,
          // The search area here
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFFE9EBEF),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                controller: _controller,
                onChanged: (text) {
                  initialSearch(text);
                },
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      color: Colors.black,
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    suffixIcon: IconButton(
                      color: Colors.black,
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                        });

                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
              ),
            ),
          )),
      body: Container(
        child: GridView.count(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          primary: false,
          shrinkWrap: true,
          children: tempSearchStore.map((e){
            return buildResultCard(e, context);
          }).toList(),),
      ),
    );
  }
}

Widget buildResultCard(data, BuildContext context) {
  return GestureDetector(
    onTap: (){
      String tappedEmail = data['email'];

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(
                isSelf: false,
                user: User(userEmail: tappedEmail),
              )));
    },
    child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 2.0,
        child: Container(
            child: Center(
                child: Text(data['fName'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                )
            )
        )
    ),
  );
}

//const Color(0xFFEDF0F6)
// Color.fromARGB(255, 253, 253, 255)
//style: TextStyle(color: Colors.grey[500]),
