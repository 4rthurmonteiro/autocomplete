import 'package:autocomplete/src/packages/package_detail.dart';
import 'package:autocomplete/src/shared/utils/colors.dart';
import 'package:autocomplete/src/shared/utils/decoration.dart';
import 'package:autocomplete/src/shared/widgets/app_box.dart';
import 'package:autocomplete/src/shared/widgets/app_divider.dart';
import 'package:autocomplete/src/shared/widgets/app_text.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pub_api_client/pub_api_client.dart';

class PackagesDetailScreen extends StatelessWidget {
  const PackagesDetailScreen({
    super.key,
    required this.packageResult,
  });

  final PackageResult packageResult;

  @override
  Widget build(BuildContext context) {
    final eventBus = context.read<EventBus>();
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBox(
                boxDecoration: appBoxDecoration,
                width: 70,
                child: IconButton(
                  onPressed: () {
                    eventBus.fire(
                      packageResult,
                    );
                    GoRouter.of(context).pushReplacement('/');
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: appPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder<PackageDetail>(
                future: getPackageDetail(
                    packageResult: packageResult, context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final detail = snapshot.data!;
                    final score = detail.score;
                    final likes = score.likeCount.toString();
                    final grantedPoints = (score.grantedPoints ?? 0).toString();
                    final popularityScore =
                        '${((score.popularityScore ?? 0.0) * 100).toStringAsFixed(1)} %';

                    return Container(
                      decoration: appSecondaryBoxDecoration,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppText(text: packageResult.package),
                          ),
                          const AppDivider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ScoreView(
                                scoreDescription: 'Likes',
                                scoreValue: likes,
                              ),
                              _ScoreView(
                                scoreDescription: 'Pub Points',
                                scoreValue: grantedPoints,
                              ),
                              _ScoreView(
                                scoreDescription: 'Popularity',
                                scoreValue: popularityScore,
                              ),
                            ],
                          ),
                          const AppDivider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppText.customColor(
                              color: appSecondaryColor,
                              text: detail.info.description,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: appPrimaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<PackageDetail> getPackageDetail({
    required PackageResult packageResult,
    required BuildContext context,
  }) async {
    final pubClient = context.read<PubClient>();

    final score = await pubClient.packageScore(
      packageResult.package,
    );

    final info = await pubClient.packageInfo(
      packageResult.package,
    );

    return PackageDetail(
      score: score,
      info: info,
    );
  }
}

class _ScoreView extends StatelessWidget {
  const _ScoreView({
    required this.scoreDescription,
    required this.scoreValue,
  });

  final String scoreValue;
  final String scoreDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: scoreValue,
        ),
        AppText.customColor(
          color: appSecondaryColor,
          text: scoreDescription.toUpperCase(),
        ),
      ],
    );
  }
}
