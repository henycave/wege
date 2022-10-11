class User{
  String name;
  String userDocumentReference;
  String userEmail;

  User({this.userDocumentReference,this.userEmail, this.name});

  String getName(){
    return name;
  }
  String getUserDocumentReference(){
    return userDocumentReference;
  }
  String getUserEmail(){
    return userEmail;
  }

}