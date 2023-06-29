import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/screens/service_info/pdf_view.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

class Policy extends StatelessWidget {
  const Policy({super.key});

  @override
  Widget build(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildPolicyBtn(() {
                Navigator.of(context, rootNavigator: true).push(
                  pageRouteBuilder(
                    page: const PDFView(type: PDFType.terms),
                    offset: const Offset(0.0, 1.0),
                  ),
                );
              }, '서비스 이용약관'),
              const SizedBox(width: 8),
              _buildPolicyBtn(() {
                Navigator.of(context, rootNavigator: true).push(
                  pageRouteBuilder(
                    page: const PDFView(type: PDFType.privacy),
                    offset: const Offset(0.0, 1.0),
                  ),
                );
              }, '개인정보처리방침'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<String>(
            future: viewModel.version,
            builder: (context, snapshot) {
              return Text(
                '버전 정보 ${(snapshot.hasData) ? snapshot.data : '-'}',
                style: WakText.txt12L.copyWith(color: WakColor.grey400),
                textAlign: TextAlign.center,
              );
            }),
      ],
    );
  }

  Widget _buildPolicyBtn(void Function() onTap, String btnName) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: WakColor.grey400.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            btnName,
            style: WakText.txt14MH.copyWith(color: WakColor.grey600),
          ),
        ),
      ),
    );
  }
}
