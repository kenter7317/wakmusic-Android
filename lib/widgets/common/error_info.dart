import 'package:flutter/material.dart';
import 'package:wakmusic/style/text_styles.dart';

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({super.key, required this.errorMsg});
  final String errorMsg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 1),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF919CA8).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(1, 6),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/ic_56_contents_info.png',
                width: 56,
                height: 56,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              style: WakText.txt14MH,
              textAlign: TextAlign.center,
            )
          ],
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
