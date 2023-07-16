import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wakmusic/main.dart';
import 'package:lottie/lottie.dart';
import 'package:wakmusic/repository/s3_repo.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/models_v2/event.dart';
import 'package:wakmusic/services/etc_repo.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/show_modal.dart';

import '../widgets/common/app_authority_pop_up.dart';

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
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller = AnimationController(vsync: this);

    S3Repository().configure();
    Provider.of<AudioProvider>(context, listen: false).init();
    Provider.of<KeepViewModel>(context, listen: false).getUser();
  }

  void _preRunBehavior() async {
    final viewModel = Provider.of<KeepViewModel>(context, listen: false);
    AppVersion version = AppVersion.parse(await viewModel.version);
    Event event = await API.check(version: version);

    switch (event.flag) {
      case AppFlag.event:
        await showModal(
          context: context,
          builder: (_) => PopUp(
            type: PopUpType.txtOneBtn,
            msg: '${event.title}\n\n${event.description ?? ''}',
            posFunc: () => SystemNavigator.pop(),
          ),
          dismissible: false,
        );
        return;
      case AppFlag.updateInfo:
        await showModal(
          context: context,
          builder: (_) => PopUp(
            type: PopUpType.txtTwoBtn,
            msg: '왁타버스 뮤직이 업데이트 되었습니다.\n최신 버전으로 업데이트 후 이용하시기 바랍니다.\n감사합니다.',
            negText: '나중에',
            posText: '업데이트 하러가기',
            posFunc: () {
              // Replace with Deep Link later
              launchUrlString('market://details?id=com.waktaverse.music');
            },
          ),
          dismissible: false,
        );
        break;
      case AppFlag.updateRequired:
        await showModal(
          context: context,
          builder: (_) => PopUp(
            type: PopUpType.txtOneBtn,
            msg: '왁타버스 뮤직이 업데이트 되었습니다.\n최신 버전으로 업데이트 후 이용하시기 바랍니다.\n감사합니다.',
            posText: '업데이트 하러가기',
            posFunc: () {
              // Replace with Deep Link later
              launchUrlString('market://details?id=com.waktaverse.music');
            },
          ),
          dismissible: false,
        );
        return;
      default:
        break;
    }

    if (!await EtcRepository().appAuthorityCheck()) {
      await _showDialog();
    }
    _navigateToHomeScreen();
  }

  Future<void> _showDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AppAuthorityPopUp();
      },
    );
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Main()),
    );
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
                ..forward().whenComplete(_preRunBehavior),
            ),
          ],
        ),
      ),
    );
  }
}
