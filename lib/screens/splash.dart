import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/main.dart';
import 'package:lottie/lottie.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller = AnimationController(vsync: this);

    Provider.of<AudioProvider>(context, listen: false).init();
    Provider.of<KeepViewModel>(context, listen: false).initUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    statusNavColor(context, ScreenType.etc);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Lottie.asset(
              'assets/lottie/splash_logo_main.json',
              controller: _controller,
              width: MediaQuery.of(context).size.width * 5 / 12,
              onLoaded: (composition) => _controller
                ..duration = composition.duration
                ..forward().whenComplete(() => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Main()),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
