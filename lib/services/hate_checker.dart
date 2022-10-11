import 'package:wege/services/networking.dart';

const apiURL = "http://10.0.2.2:5000/predict";
// const apiURL = "http://192.168.190.141:5000/predict";
class HateChecker{
  Future<dynamic> checkHate(String text) async{

    var jsonText = {"values": ["$text"]};
    Networking networking = Networking(url:apiURL, json: jsonText);
    print('here');
    var result = await networking.getData();
    print(result);
    //print(result.toString());
    return result.toString();
  }
  
  
  
 }
void main()async{
  var response = await HateChecker().checkHate("");
  print(response);

}