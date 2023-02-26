import 'package:autocomplete/src/packages/packages_detail_screen.dart';
import 'package:autocomplete/src/packages/packages_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pub_api_client/pub_api_client.dart';

class AutoCompleteApp extends StatelessWidget {
  const AutoCompleteApp({
    super.key,
    required this.pubClient,
  });

  final PubClient pubClient;

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: pubClient,
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PackagesScreen(key: Key('packages')),
        routes: [
          GoRoute(
            path: 'details',
            builder: (context, state) {
              final packageResult = state.extra! as PackageResult;

              return PackagesDetailScreen(
                key: const Key(
                  'details',
                ),
                packageResult: packageResult,
              );
            },
          ),
        ],
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Autocomplete',
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
