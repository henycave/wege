import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Networking {
  String url;
  var json;

  Networking({this.url, this.json});

  Future getData() async {
    final link = Uri.encodeFull(url);
    final headers = {HttpHeaders.contentTypeHeader: " application/json"};
    //var jsonText = {"values": ["አበበ በሶ በላ"]};
    var postBody = jsonEncode(json);
    var response = await http.post(link,headers: headers, body: postBody);
    final getResponse =
    await http.post(response.headers["location"], body: postBody, headers:headers);

    if (getResponse.statusCode == 200) {
      return jsonDecode(getResponse.body);
    } else {
      print(response.statusCode);
    }
  }
}

