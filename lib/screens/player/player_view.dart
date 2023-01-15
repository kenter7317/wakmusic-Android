import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/widgets/player/player_button.dart';

import '../../style/text_styles.dart';

class Player extends StatelessWidget {
  const Player({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WakColor.grey100,
      body: _buildBody(context),
      bottomNavigationBar: _buildPlayerBottomNav(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    var status_height = MediaQuery.of(context).padding.top;
    var height = MediaQuery.of(context).size.height - status_height;
    var width = MediaQuery.of(context).size.width;

    var blank = 0;
    if(height >= 732) {
      blank = ((height - (width - 50) / (16/9) - 334 - 12) / 20).floor();
    } else {
      blank = ((height - (width - 50) / (16/9) - 286 - 12) / 20).floor();
    }

    return Stack(
      children: [
        Positioned(
          //left: -83,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: status_height + 48 + ((width - 50) / (16/9)) + (blank * 4 + 12) - 36,
              width: width * 1.44,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      'https://i.ytimg.com/vi/lLIpFxWtqCQ/hqdefault.jpg'),
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6),
                    BlendMode.dstATop
                  )
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 200,
                      sigmaY: 200,
                    ),
                    child: Container(
                    ),
                ),
              ),
            ),
          ),
        ),
        _buildPlayer(context, blank),
        Positioned(
          top: 8 + MediaQuery.of(context).padding.top,
          left: 20,
          height: 32,
          width: 32,
          child: GestureDetector(
            onTap: () => {},
            child: SvgPicture.asset(
              'assets/icons/ic_32_arrow_bottom.svg',
              width: 32,
              height: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer(BuildContext context, int blank) {

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        _buildTitle(context),
        SizedBox(height: blank * 4 + 12),
        _buildAlbumImage(context),
        SizedBox(height: blank * 4 - 4),
        _buildLyrics(context),
        SizedBox(height: blank * 4),
        _buildAudioProgressBar(context),
        SizedBox(height: blank * 4),
        const PlayerButton(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: Column(
          children: [
            Text(
              '리와인드 (RE:WIND)',
              style: WakText.txt16M,
            ),
            Text(
              '이세계아이돌',
              style: WakText.txt14M.copyWith(color: Colors.black.withOpacity(0.60)),
            )
          ],
      )),
    );
  }

  Widget _buildAlbumImage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: AspectRatio(
        aspectRatio: 16/9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                  'https://i.ytimg.com/vi/lLIpFxWtqCQ/hqdefault.jpg'),
            ),
            /*colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.1),
                        BlendMode.dstATop),*/
          ),
        ),
      ),
    );
  }

  Widget _buildLyrics(BuildContext context) {
    var height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var lyricsList = [
      '기억나 우리 처음 만난 날',
      '내게 오던 너의 그 미소가',
      '마치 날 알고있던 것처럼',
      '매일 스쳐 지나 가던 바람 처럼',
      '가끔은 우리 사이가 멀어질까'
    ];
    return Column(
      children: List<Widget>.generate(height >= 732 ? 5 : 3, (index) {
        return SizedBox(
          height: 24,
          child: Text(
            lyricsList[index],
            style: WakText.txt14MH.copyWith(color: WakColor.grey500),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAudioProgressBar(BuildContext context) {
    /*return ValueListenableBuilder(
        valueListenable: ,
        builder: (_, value, __){
          return ProgressBar(
            progress: null,
          );
        }
    );*/
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const ProgressBar(
            progress: Duration.zero,
            total: Duration(),
            barHeight: 2,
            baseBarColor: WakColor.grey300,
            progressBarColor: WakColor.lightBlue,
            thumbRadius: 4,
            thumbColor: WakColor.lightBlue,
            timeLabelLocation: TimeLabelLocation.none,
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0:00',
                style: WakText.txt12MH.copyWith(color: WakColor.lightBlue),
              ),
              Text(
                '5:00',
                style: WakText.txt12MH.copyWith(color: WakColor.grey400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(
          color: WakColor.grey100,
        ))
      ),
      height: 56,
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 3, 0, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => {},
              child: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/ic_32_heart_on.svg'),
                    Text(
                      '1.1만',
                      style: WakText.txt12M.copyWith(color: WakColor.pink),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => {},
              child: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/ic_32_views.svg'),
                    Text(
                      '1.1만',
                      style: WakText.txt12M.copyWith(color: WakColor.grey400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => {},
              child: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/ic_32_playadd_900.svg'),
                    Text(
                      '노래담기',
                      style: WakText.txt12M.copyWith(color: WakColor.grey400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => {},
              child: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/ic_32_play_list.svg'),
                    Text(
                      '재생목록',
                      style: WakText.txt12M.copyWith(color: WakColor.grey400,
                    ),)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
