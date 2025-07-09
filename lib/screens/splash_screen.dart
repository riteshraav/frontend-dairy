
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:take8/model/admin.dart';
import 'package:take8/screens/home_screen.dart';
import 'package:take8/service/admin_service.dart';
import '../screens/auth_screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();

    _handleSplashLogic();
  }

  Future<void> _handleSplashLogic() async {
    final stopwatch = Stopwatch()..start();

    // Start both timer and login check
    final authFuture = AdminService().directLogin();
    await Future.wait([
      authFuture,
      Future.delayed(Duration(seconds: 1)), // minimum splash time
    ]);

    final directLogin = await authFuture;
    print('directLogin is $directLogin');

    // Proceed to next screen
    if (!mounted) return;
    if (!directLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(true)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // "Welcome" text with scale and fade animations
            // ScaleTransition(
            //   scale: _scaleAnimation,
            //   child: FadeTransition(
            //     opacity: _fadeAnimation,
            //     child: const Text(
            //       "Welcome",
            //       style: TextStyle(
            //         fontSize: 32,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.deepPurple,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 140), // 7 cm gap
            // Logo with fade animation
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 140), // 7 cm gap
            // "BINARY" text with fade animation
            // FadeTransition(
            //   opacity: _fadeAnimation,
            //   child: const Text(
            //     'B I N A R Y',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       fontSize: 36,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.indigo,
            //       letterSpacing: 4.0,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}