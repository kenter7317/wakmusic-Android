import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/exitable.dart';

class OSSDetailView extends StatelessWidget {
  const OSSDetailView({super.key, required this.name, required this.license});
  final String name, license;

  @override
  Widget build(BuildContext context) {
    return DismissibleView(
      onDismissed: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        body: Exitable(
          onExitable: (scope) {
            if (scope == ExitScope.openedPageRouteBuilder) {
              Navigator.pop(context);
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                Header(
                  type: HeaderType.back,
                  headerTxt: name,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      license,
                      style: WakText.txt14MH,
                      maxLines: 1024,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
