import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pub_api_client/pub_api_client.dart';

class PackagesScreen extends HookWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pubClient = context.read<PubClient>();
    final autocompleteState = useValueNotifier(false);
    return SafeArea(
      child: Scaffold(
        body: AnimatedBuilder(
          animation: autocompleteState,
          builder: (context, _) => autocompleteState.value
              ? Autocomplete<PackageResult>(
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
                  onSelected: (packageResult) => GoRouter.of(context).go(
                    '/details',
                    extra: packageResult,
                  ),
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
                )
              : IconButton(
                  onPressed: () => autocompleteState.value = true,
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
        ),
      ),
    );
  }
}
