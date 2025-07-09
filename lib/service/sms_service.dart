import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
class SmsService{
    final ip = "${CustomWidgets.getIp()}/sms";
    static Future<bool> sendSms(String phone,String msg)
    async {
      final url = Uri.parse("${CustomWidgets.getIp()}/sms/send/+91$phone/$msg");
        final response = await http.post(url);
        try{
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
    catch(e){
          throw(e);
    }
  }
  static Future<String> sendOtp(String phone,String msg)
  async {
    final url = Uri.parse("${CustomWidgets.getIp()}/sms/sendOtp/+91$phone/$msg");
    final response = await http.post(url);
    if(response.statusCode == 200)
      {
        return response.body;
      }
    else{
      return response.body;
    }
  }
}