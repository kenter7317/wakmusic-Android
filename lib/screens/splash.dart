import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakmusic/main.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin{

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _controller = AnimationController(vsync: this);
    
    Future.delayed(
      const Duration(seconds: 5), 
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Main()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Lottie.asset(
              'assets/lottie/Splash_Logo_Main.json',
              controller: _controller,
              width: MediaQuery.of(context).size.width * 5 / 12,
              onLoaded: (composition) => _controller
                ..duration = composition.duration
                ..forward(),
            ),
          ],
        ),
      ),
    );
  }
}