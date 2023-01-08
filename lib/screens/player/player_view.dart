import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';

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
    return Stack(
      children: [
        Positioned(
          left: -83,
          child: Container(
            height: 300,
            width: 540,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: const NetworkImage(
                    'https://i.ytimg.com/vi/lLIpFxWtqCQ/hqdefault.jpg'),
              ),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 100,
            sigmaY: 100,
          ),
          child: Container(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        _buildPlayer(context),
      ],
    );
  }

  Widget _buildPlayer(BuildContext context){
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 2,
          ),
          _buildTitle(context),
          SizedBox(
            height: 54,
          ),
          _buildAlbumImage(context),
          SizedBox(
            height: 40,
          ),
          _buildLyrics(context),
          SizedBox(
            height: 43,
          ),
          _buildAudioProgressBar(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context){
    return Center(
        child: Column(
          children: [
            Text(
              '리와인드 (RE:WIND)',
              style: WakText.txt16M,
            ),
            Text(
              '이세계아이돌',
              style: WakText.txt14M.copyWith(
                  color: Colors.black.withOpacity(0.60)
              ),
            )
          ],
        )
    );
  }

  Widget _buildAlbumImage(BuildContext context){
    return Container(
      height: 180,
      width: 324,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: const NetworkImage(
              'https://i.ytimg.com/vi/lLIpFxWtqCQ/hqdefault.jpg'),
        ),
        /*colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.1),
                    BlendMode.dstATop),*/
      ),
    );
  }

  Widget _buildLyrics(BuildContext context){
    return Column(
      children: [
        Text(
          '기억나 우리 처음 만난 날',
          style: WakText.txt14MH.copyWith(color: WakColor.grey500),
        ),
        Text(
          '내게 오던 너의 그 미소가',
          style: WakText.txt14MH.copyWith(color: WakColor.grey500),
        ),
        Text(
          '마치 날 알고있던 것처럼',
          style: WakText.txt14MH.copyWith(color: WakColor.lightBlue),
        ),
        Text(
          '매일 스쳐 지나 가던 바람 처럼',
          style: WakText.txt14MH.copyWith(color: WakColor.grey500),
        ),
        Text(
          '가끔은 우리 사이가 멀어질까',
          style: WakText.txt14MH.copyWith(color: WakColor.grey500),
        ),
      ],
    );
  }

  Widget _buildAudioProgressBar(BuildContext context){
    /*return ValueListenableBuilder(
        valueListenable: ,
        builder: (_, value, __){
          return ProgressBar(
            progress: null,
          );
        }
    );*/
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ProgressBar(
            progress: Duration.zero,
            total: Duration(),
            barHeight: 2,
            baseBarColor: WakColor.grey300,
            progressBarColor: WakColor.lightBlue,
            thumbRadius: 4,
            thumbColor: WakColor.lightBlue,
            timeLabelLocation: TimeLabelLocation.none,
          ),
          SizedBox(
            height: 7,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0:00',
                style: WakText.txt12MH.copyWith(
                  color: WakColor.lightBlue
                ),
              ),
              Text(
                '5:00',
                style: WakText.txt12MH.copyWith(
                  color: WakColor.grey400
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBottomNav(BuildContext context){
    return Container(
        height: 56,
        color: Colors.white,
        child: Row(

        ),
    );
  }
}
