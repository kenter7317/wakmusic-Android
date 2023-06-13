import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/screens/service_info/oss_detail_view.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/oss_licenses.dart';
import 'package:wakmusic/widgets/common/item.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

class OSSView extends StatelessWidget {
  const OSSView({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissibleView(
      onDismissed: () {
        ExitScope.remove = ExitScope.ossLicense;
        Navigator.pop(context);
      },
      child: Scaffold(
        body: Exitable(
          scopes: const [ExitScope.ossLicense],
          onExitable: (scope) {
            if (scope == ExitScope.ossLicense) {
              ExitScope.remove = ExitScope.ossLicense;
              Navigator.pop(context);
            }
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          const Header(
            type: HeaderType.back,
            headerTxt: '오픈소스 라이선스',
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: ossLicenses.length,
              itemBuilder: (context, idx) {
                Package package = ossLicenses[idx];
                return Item(
                  onTap: () => Navigator.push(
                    context,
                    pageRouteBuilder(
                      page: OSSDetailView(
                        name: package.name,
                        license: package.license ?? '',
                      ),
                      scope: ExitScope.ossDetail,
                    ),
                  ),
                  text: package.name,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
