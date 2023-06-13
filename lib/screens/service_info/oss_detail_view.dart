import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/exitable.dart';

class OSSDetailView extends StatelessWidget {
  const OSSDetailView({super.key, required this.name, required this.license});
  final String name, license;

  @override
  Widget build(BuildContext context) {
    return DismissibleView(
      onDismissed: () {
        ExitScope.remove = ExitScope.ossDetail;
        Navigator.pop(context);
      },
      child: Scaffold(
        body: Exitable(
          scopes: const [ExitScope.ossDetail],
          onExitable: (scope) {
            if (scope == ExitScope.ossDetail) {
              ExitScope.remove = ExitScope.ossDetail;
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
