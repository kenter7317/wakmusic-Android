import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/service_info/oss_view.dart';
import 'package:wakmusic/screens/service_info/pdf_view.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/item.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakmusic/widgets/show_modal.dart';

class ServiceInfoView extends StatelessWidget {
  const ServiceInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissibleView(
      onDismissed: () => Navigator.pop(context),
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return SafeArea(
      child: Column(
        children: [
          const Header(
            type: HeaderType.back,
            headerTxt: '서비스 정보',
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Item(
                        onTap: () =>
                            Navigator.of(context, rootNavigator: true).push(
                          pageRouteBuilder(
                            page: const PDFView(type: PDFType.terms),
                            offset: const Offset(0.0, 1.0),
                          ),
                        ),
                        text: '서비스 이용약관',
                      ),
                      Item(
                        onTap: () =>
                            Navigator.of(context, rootNavigator: true).push(
                          pageRouteBuilder(
                            page: const PDFView(type: PDFType.privacy),
                            offset: const Offset(0.0, 1.0),
                          ),
                        ),
                        text: '개인정보 처리 방침',
                      ),
                      Item(
                        onTap: () => Navigator.push(
                          context,
                          pageRouteBuilder(
                            page: const OSSView(),
                          ),
                        ),
                        text: '오픈소스 라이선스',
                      ),
                      Item(
                        onTap: () async {
                          Directory tempDir = await getTemporaryDirectory();
                          showModal(
                            context: context,
                            builder: (_) => PopUp(
                              type: PopUpType.txtTwoBtn,
                              msg: '캐시 데이터(${_getSize(tempDir)})를 지우시겠습니까?',
                              posFunc: () {
                                if (tempDir.existsSync()) {
                                  tempDir.deleteSync(recursive: true);
                                }
                              },
                            ),
                          );
                        },
                        text: '캐시 데이터 지우기',
                      ),
                      Container(
                        height: 61,
                        padding: const EdgeInsets.fromLTRB(20, 0, 24, 0),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: WakColor.grey200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '버전정보',
                                style: WakText.txt16M
                                    .copyWith(color: WakColor.grey900),
                              ),
                            ),
                            const SizedBox(width: 16),
                            FutureBuilder<String>(
                                future: viewModel.version,
                                builder: (context, snapshot) {
                                  return Text(
                                    '${(snapshot.hasData) ? snapshot.data : '-'}',
                                    style: WakText.txt12L
                                        .copyWith(color: WakColor.grey500),
                                    textAlign: TextAlign.right,
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSize(Directory tempDir) {
    double value = _getTotalSizeOfFilesInDir(tempDir);
    return _renderSize(value);
  }

  double _getTotalSizeOfFilesInDir(final FileSystemEntity file) {
    if (file is File) {
      return file.lengthSync().toDouble();
    } else if (file is Directory) {
      List children = file.listSync();
      double total = 0;
      for (FileSystemEntity child in children) {
        total += _getTotalSizeOfFilesInDir(child);
      }
      return total;
    }
    return 0;
  }

  String _renderSize(double value) {
    List<String> unitArr = [' B', ' KB', ' MB', ' GB'];
    int index = 0;
    while (value > 1024 && index < 3) {
      index++;
      value = value / 1024;
    }
    return value.toStringAsFixed(2) + unitArr[index];
  }
}
