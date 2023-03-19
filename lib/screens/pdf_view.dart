import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/header.dart';

enum PDFType {
  terms('서비스 이용약관'),
  privacy('개인정보처리방침');

  const PDFType(this.str);
  final String str;
}

class PDFView extends StatefulWidget {
  const PDFView({super.key, required this.type});
  final PDFType type;

  @override
  State<PDFView> createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openData(
        InternetFile.get('$staticBaseUrl/document/${widget.type.name}.pdf'),
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Header(
              type: HeaderType.close, 
              headerTxt: widget.type.str,
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(color: Colors.black.withOpacity(0.4)),
                  Scrollbar(
                    child: PdfView(
                      controller: _pdfController,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      builders: PdfViewBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(loaderSwitchDuration: Duration.zero),
                        documentLoaderBuilder: (_) => const Center(
                          child: CircularProgressIndicator(color: WakColor.grey25),
                        ),
                        errorBuilder: (_, error) => Container(
                          alignment: Alignment.center,
                          color: WakColor.grey100,
                          child: const ErrorInfo(errorMsg: '파일을 불러오는 데 문제가 발생했습니다.'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: WakColor.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '확인',
            style: WakText.txt18M.copyWith(color: WakColor.grey25),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
