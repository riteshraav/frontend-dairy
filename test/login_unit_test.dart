// import 'package:flutter_test/flutter_test.dart';
// import 'package:take8/model/admin.dart';
// import 'package:take8/service/admin_service.dart';
//
//
// void main() {
//   group('Admin login unit test', () {
//     test('Admin login success', () async {
//       final service = AdminService();
//       final admin = Admin(id: '1', password: '1');
//
//       final result = await service.loginUserAuth(admin);
//       expect(result, 'Successful'); // Adjust based on your actual logic
//     });
//
//     test('Admin login failure', () async {
//       final service = AdminService();
//       final admin = Admin(id: '1', password: '2');
//
//       final result = await service.loginUserAuth(admin);
//       expect(result != 'Successful', true); // Expecting error
//     });
//   });
// }
import 'package:flutter_test/flutter_test.dart';
import 'package:take8/model/admin.dart';
import 'package:take8/service/admin_service.dart';

void main(){
  group('Login page test group:', (){
    final adminService = AdminService();
    test('Correct case of login', ()async{
      final admin = Admin(id: '1',password: '1');
      final result =await adminService.loginUserAuth(admin);
      expect(result, "Successful");
    });
  });
}