import 'package:autocomplete/src/packages/local_storage_persistence.dart';
import 'package:autocomplete/src/shared/utils/colors.dart';
import 'package:autocomplete/src/shared/utils/decoration.dart';
import 'package:autocomplete/src/shared/widgets/app_box.dart';
import 'package:autocomplete/src/shared/widgets/app_divider.dart';
import 'package:autocomplete/src/shared/widgets/app_text.dart';
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

class _Content extends HookWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final autocompleteState = useValueNotifier(false);
    final showHistory = useValueNotifier(true);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            _PackageSearchView(
              autocompleteState: autocompleteState,
              showHistory: showHistory,
            ),
            const SizedBox(
              height: 10,
            ),
            AnimatedBuilder(
              animation: Listenable.merge(
                [
                  autocompleteState,
                  showHistory,
                ],
              ),
              builder: (context, _) =>
                  autocompleteState.value && showHistory.value
                      ? const _HistoryView()
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _PackageSearchView extends HookWidget {
  _PackageSearchView({
    required this.autocompleteState,
    required this.showHistory,
  });

  final ValueNotifier<bool> autocompleteState;
  final ValueNotifier<bool> showHistory;

  double myValue = 50.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * .75;
    final pubClient = context.read<PubClient>();
    final localStoragePersistence = context.read<LocalStoragePersistence>();
    final router = GoRouter.of(context);

    return AnimatedBuilder(
      animation: autocompleteState,
      builder: (context, _) => AnimatedContainer(
        width: myValue,
        duration: const Duration(seconds: 1),
        decoration: appBoxDecoration,
        child: autocompleteState.value
            ? Autocomplete<PackageResult>(
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) =>
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    cursorColor: appPrimaryColor,
                    controller: textEditingController,
                    focusNode: focusNode..requestFocus(),
                    onChanged: (value) {
                      if (value.length > 1) {
                        showHistory.value = false;
                      } else {
                        showHistory.value = true;
                      }
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: const TextStyle(
                      color: appPrimaryColor,
                    ),
                  ),
                ),
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: appBackgroundColor,
                        child: Container(
                          width: MediaQuery.of(context).size.width * .75,
                          decoration: appSecondaryBoxDecoration,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0, vertical: 5),
                                child: GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: AppText(
                                    text: option.package,
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const AppDivider(),
                            itemCount: options.length,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : IconButton(
                iconSize: 30,
                onPressed: () {
                  myValue = width;
                  autocompleteState.value = true;
                },
                icon: const Icon(
                  Icons.search,
                  color: appPrimaryColor,
                ),
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
              return const AppBox(child: AppText(text: 'No Recent Searches'));
            }

            return Container(
              width: MediaQuery.of(context).size.width * .75,
              decoration: appSecondaryBoxDecoration,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AppText(text: 'Recent Searches'),
                  ),
                  const AppDivider(),
                  ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 5),
                      child: GestureDetector(
                        onTap: () {
                          GoRouter.of(context).go(
                            '/details',
                            extra: history[index],
                          );
                        },
                        child: AppText(
                          text: history[index].package,
                        ),
                      ),
                    ),
                    separatorBuilder: (_, __) => const AppDivider(),
                    itemCount: history.length,
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
