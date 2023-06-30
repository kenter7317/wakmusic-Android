import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/text_with_dot.dart';

import '../../services/etc_repo.dart';

class AppAuthorityPopUp extends StatelessWidget {
  const AppAuthorityPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: SizedBox(
        width: 335,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      '앱 접근 권한 안내',
                      style: WakText.txt22B.copyWith(color: WakColor.grey900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '선택적 접근 권한',
                      style: WakText.txt18M.copyWith(color: WakColor.grey900),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPermission(
                    'camera',
                    '카메라',
                    '버그 제보 시 사진 촬영을 위한 권한',
                  ),
                  const SizedBox(height: 8),
                  _buildPermission(
                    'album',
                    '앨범',
                    '버그 제보 시 파일 첨부를 위한 권한',
                  ),
                  const SizedBox(height: 8),
                  _buildPermission(
                    'alarm',
                    '알림',
                    '백그라운드 음악 재생을 위한 권한',
                  ),
                  const SizedBox(height: 8),
                  _buildPermission(
                    'app',
                    '다른 앱 위에 표시',
                    '백그라운드 음악 재생을 위한 권한',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1, color: WakColor.grey200),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: const [
                        TextWithDot(
                            text:
                                '선택적 접근 권한은 서비스 사용 중 필요한 시점에 동의를 받고 있습니다. 허용하지 않으셔도 서비스 이용이 가능합니다.'),
                        SizedBox(height: 4),
                        TextWithDot(text: '접근 권한 변경 방법 : 설정 > 왁타버스 뮤직'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _requestPermission().whenComplete(() => Navigator.pop(context));
              },
              child: Container(
                height: 56,
                decoration: const BoxDecoration(
                  color: WakColor.lightBlue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    '확인',
                    style: WakText.txt18M.copyWith(color: WakColor.grey25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermission(
      String iconName, String permissionName, String description) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/ic_32_${iconName}_circle.svg',
          width: 32,
          height: 32,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                permissionName,
                style: WakText.txt16M.copyWith(color: WakColor.grey900),
                textAlign: TextAlign.left,
              ),
              Text(
                description,
                style: WakText.txt14L.copyWith(color: WakColor.grey500),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestPermission() async {
    Map<Permission, PermissionStatus> permissionStatuses = await [
      Permission.camera,
      Permission.storage,
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
