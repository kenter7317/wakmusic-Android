import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/btn_with_icon.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/keep/bot_sheet.dart';
import 'package:wakmusic/widgets/keep/playlist_tile.dart';
import 'package:wakmusic/widgets/show_modal.dart';

import '../../services/etc_repo.dart';

class AppAuthorityPopUp extends StatelessWidget {
  const AppAuthorityPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0)
      ),
      child: Container(
        width: 335,
        height: 463,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                children: [
                  Center(
                    child: Text('앱 접근 권한 안내',
                      style: WakText.txt22B.copyWith(color: WakColor.grey900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('선택적 접근 권한',
                      style: WakText.txt18M.copyWith(color: WakColor.grey900),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 16,),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_32_camera_circle.svg',
                        width: 32,
                        height: 32,
                      ),
                      SizedBox(width: 8,),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('카메라',
                            style: WakText.txt16M.copyWith(color: WakColor.grey900),
                            textAlign: TextAlign.left,
                          ),
                          Text('버그 제보 시 사진 촬영을 위한 권한',
                            style: WakText.txt14L.copyWith(color: WakColor.grey500),
                            textAlign: TextAlign.left,
                          )
                        ],
                      ))
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_32_album_circle.svg',
                        width: 32,
                        height: 32,
                      ),
                      SizedBox(width: 8,),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('앨범',
                            style: WakText.txt16M.copyWith(color: WakColor.grey900),
                            textAlign: TextAlign.left,
                          ),
                          Text('버그 제보 시 파일 첨부를 위한 권한',
                            style: WakText.txt14L.copyWith(color: WakColor.grey500),
                            textAlign: TextAlign.left,
                          )
                        ],
                      ))
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_32_alarm_circle.svg',
                        width: 32,
                        height: 32,
                      ),
                      SizedBox(width: 8,),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('알림',
                            style: WakText.txt16M.copyWith(color: WakColor.grey900),
                            textAlign: TextAlign.left,
                          ),
                          Text('백그라운드 음악 재생을 위한 권한',
                            style: WakText.txt14L.copyWith(color: WakColor.grey500),
                            textAlign: TextAlign.left,
                          )
                        ],
                      ))
                    ],
                  ),
                  SizedBox(height: 16,),
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  width: 1,
                                  color: WakColor.grey200
                              )
                          )
                      ),
                      padding: EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/ic_16_dot.svg',
                                width: 16,
                                height: 16,
                              ),
                              Expanded(
                                child: Text('선택적 접근 권한은 서비스 사용 중 필요한 시점에 동의를 받고 있습니다. 허용하지 않으셔도 서비스 이용이 가능합니다.',
                                  style: WakText.txt12L.copyWith(color: WakColor.grey500),
                                  textAlign: TextAlign.left ,
                                  overflow: TextOverflow.visible,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/ic_16_dot.svg',
                                width: 16,
                                height: 16,
                              ),
                              Expanded(
                                child: Text('접근 권한 변경 방법 : 설정 > 왁타버스 뮤직',
                                  style: WakText.txt12L.copyWith(color: WakColor.grey500),
                                  textAlign: TextAlign.left ,
                                  overflow: TextOverflow.visible,
                                  maxLines: 3,
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                  ),
                  SizedBox(height: 30,),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await _requestPermission();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: WakColor.lightBlue,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.0))
                  ),
                  child: Center(
                    child: Text('확인',
                      style: WakText.txt18M.copyWith(color: WakColor.grey25),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    Map<Permission, PermissionStatus> permissionStatuses = await [
      Permission.camera,
      Permission.storage,
      Permission.systemAlertWindow,
    ].request();

    // 허용/비허용의 차이가 없기에 주석처리
    /*if((permissionStatuses[Permission.camera]?.isGranted ?? false) &&
        (permissionStatuses[Permission.storage]?.isGranted ?? false)){
      //인증 완료 로직
    }else{
      //거부 로직
    }*/

    EtcRepository().appAuthoritySave();
  }
}
