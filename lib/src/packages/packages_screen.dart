import 'package:autocomplete/src/packages/local_storage_persistence.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pub_api_client/pub_api_client.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: _Content(),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _PackageSearchView(),
        SizedBox(
          height: 10,
        ),
        _HistoryView(),
      ],
    );
  }
}

class _PackageSearchView extends HookWidget {
  const _PackageSearchView();

  @override
  Widget build(BuildContext context) {
    final autocompleteState = useValueNotifier(false);
    final pubClient = context.read<PubClient>();
    final localStoragePersistence = context.read<LocalStoragePersistence>();
    final router = GoRouter.of(context);
    return AnimatedBuilder(
      animation: autocompleteState,
      builder: (context, _) => autocompleteState.value
          ? Column(
              children: [
                Autocomplete<PackageResult>(
                  optionsBuilder: (value) async {
                    if (value.text.length > 1) {
                      final result = await pubClient.search(
                        value.text,
                      );
                      if (result.packages.length > 5) {
                        return result.packages.sublist(0, 5);
                      }

                      return result.packages;
                    }

                    return [];
                  },
                  displayStringForOption: (packageResult) =>
                      packageResult.package,
                  onSelected: (packageResult) async {
                    await localStoragePersistence
                        .fetchPackageResults(packageResult);

                    router.go(
                      '/details',
                      extra: packageResult,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);

                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(
                                  option.package,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : IconButton(
              onPressed: () => autocompleteState.value = true,
              icon: const Icon(
                Icons.search,
              ),
            ),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  late final LocalStoragePersistence localStoragePersistence;
  @override
  void initState() {
    super.initState();
    localStoragePersistence = context.read<LocalStoragePersistence>();
    context.read<EventBus>().on<PackageResult>().listen(
      (packageResultEvent) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PackageResult>>(
        future: localStoragePersistence.getPackageResultHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final history = snapshot.data!;

            if (history.isEmpty) {
              return const Text(
                'No Recent Searches',
              );
            }

            return Column(
              children: [
                const Text(
                  'Recent Searches',
                ),
                ...history
                    .map(
                      (e) => Text(
                        e.package,
                      ),
                    )
                    .toList(),
              ],
            );
          }
          return const Text(
            'No Recent Searches',
          );
        });
  }
}
