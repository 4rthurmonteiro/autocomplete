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
    final pubClient = context.read<PubClient>();
    final eventBus = context.read<EventBus>();
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            IconButton(
              onPressed: () {
                eventBus.fire(
                  packageResult,
                );
                GoRouter.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
              ),
            ),
            Text(packageResult.package),
            FutureBuilder<PackageScore>(
              future: pubClient.packageScore(
                packageResult.package,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final score = snapshot.data!;
                  final likes = score.likeCount.toString();
                  final grantedPoints = (score.grantedPoints ?? 0).toString();
                  final popularityScore =
                      '${((score.popularityScore ?? 0.0) * 100).toStringAsFixed(1)} %';
                  return Row(
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
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            FutureBuilder<PubPackage>(
              future: pubClient.packageInfo(
                packageResult.package,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!.description,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
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
        Text(
          scoreValue,
        ),
        Text(
          scoreDescription.toUpperCase(),
        ),
      ],
    );
  }
}
