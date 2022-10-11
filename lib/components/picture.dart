import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> _picture(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                GestureDetector(
                  child: new Text('Take a picture'),
                  onTap: () async {
                    await ImagePicker().getImage(
                      source: ImageSource.camera,
                    );
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                GestureDetector(
                  child: new Text('Select from gallery'),
                  onTap: () async {
                    await ImagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      });
}