import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakmusic/screens/contact/contact_view.dart';

const email = 'contact\x40wakmusic.xyz';
const mailBody = <ContactAbout, String>{
  ContactAbout.bug: bug,
  ContactAbout.feature: feature,
  ContactAbout.addSong: addSong,
  ContactAbout.editSong: editSong,
  ContactAbout.chart: chart,
};

String mail(
  ContactAbout type,
  String version,
  String device,
  String os,
  int sdk,
  String nickname,
) {
  assert(type != ContactAbout.select);
  return '${mailBody[type]!}\n$footer\n\n왁타버스 뮤직 v$version\n$device / Android $os (API $sdk)\n닉네임: $nickname';
}

const bug = '''
겪으신 버그에 대해 설명해 주세요.





''';
const feature = '''
제안해 주고 싶은 기능에 대해 설명해 주세요.





''';
const addSong = '''
· 이세돌 분들이 부르신걸 이파리분들이 개인소장용으로 일부공개한 영상을 올리길 원하시면 ‘은수저’님에게 왁물원 채팅으로 부탁드립니다.
· 왁뮤에 들어갈 수 있는 기준을 충족하는지 꼭 확인하시고 추가 요청해 주세요.

아티스트:

노래 제목:

유튜브 링크:

내용:



''';
const editSong = '''
조회수가 이상한 경우는 반응 영상이 포함되어 있을 수 있습니다.

아티스트:

노래 제목:

유튜브 링크:

내용:



''';
const chart = '''
문의하실 내용을 적어주세요.





''';
const footer = '''
-------------------------------------------
* 자동으로 작성된 시스템 정보입니다. 원활한 문의를 위해서 삭제하지 말아주세요.
''';
