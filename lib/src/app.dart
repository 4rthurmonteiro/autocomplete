import 'package:autocomplete/src/packages/local_storage_persistence.dart';
import 'package:autocomplete/src/packages/packages_detail_screen.dart';
import 'package:autocomplete/src/packages/packages_screen.dart';
import 'package:autocomplete/src/shared/utils/colors.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pub_api_client/pub_api_client.dart';

class AutoCompleteApp extends StatelessWidget {
  const AutoCompleteApp({
    super.key,
    required this.pubClient,
    required this.localStoragePersistence,
    required this.eventBus,
  });

  final PubClient pubClient;
  final LocalStoragePersistence localStoragePersistence;
  final EventBus eventBus;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(
          value: localStoragePersistence,
        ),
        Provider.value(
          value: pubClient,
        ),
        Provider.value(
          value: eventBus,
        )
      ],
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
        builder: (context, state) => const PackagesScreen(
          key: Key(
            'packages',
          ),
        ),
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
      theme: ThemeData(
        scaffoldBackgroundColor: appBackgroundColor,
      ),
      title: 'Autocomplete',
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
