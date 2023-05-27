import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/pdf_view.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';
import 'package:path_provider/path_provider.dart';

class ServiceInfo extends StatelessWidget {
  const ServiceInfo({super.key});

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
                      _buildItem(
                        context,
                        onTap: () =>
                            Navigator.of(context, rootNavigator: true).push(
                          pageRouteBuilder(
                            page: const PDFView(type: PDFType.terms),
                            offset: const Offset(0.0, 1.0),
                          ),
                        ),
                        text: '서비스 이용약관',
                      ),
                      _buildItem(
                        context,
                        onTap: () =>
                            Navigator.of(context, rootNavigator: true).push(
                          pageRouteBuilder(
                            page: const PDFView(type: PDFType.privacy),
                            offset: const Offset(0.0, 1.0),
                          ),
                        ),
                        text: '개인정보 처리 방침',
                      ),
                      _buildItem(
                        context,
                        onTap: () {/* open source licence */},
                        text: '오픈소스 라이선스',
                      ),
                      _buildItem(
                        context,
                        onTap: () async {
                          Directory tempDir = await getTemporaryDirectory();
                          print('cache size: ${_getSize(tempDir)}');
                          if (tempDir.existsSync()) {
                            tempDir.deleteSync(recursive: true);
                          }
                        },
                        text: '캐시 데이터 지우기',
                      ),
                      _buildItem(
                        context,
                        text: '버전정보',
                        isVersion: true,
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

  String  _renderSize(double value) {
    List<String> unitArr = ['B', 'KB', 'MB', 'GB'];
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    return value.toStringAsFixed(2) + unitArr[index];
  }

  Widget _buildItem(
    BuildContext context, {
    void Function()? onTap,
    required String text,
    bool isVersion = false,
  }) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 61,
        padding: EdgeInsets.fromLTRB(20, 0, (isVersion) ? 24 : 20, 0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: WakColor.grey200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: WakText.txt16M.copyWith(color: WakColor.grey900),
              ),
            ),
            const SizedBox(width: 16),
            (isVersion)
                ? FutureBuilder<String>(
                    future: viewModel.version,
                    builder: (context, snapshot) {
                      return Text(
                        '${(snapshot.hasData) ? snapshot.data : '-'}',
                        style: WakText.txt12L.copyWith(color: WakColor.grey500),
                        textAlign: TextAlign.right,
                      );
                    })
                : SvgPicture.asset(
                    'assets/icons/ic_24_arrow_right.svg',
                    width: 24,
                    height: 24,
                  ),
          ],
        ),
      ),
    );
  }
}
