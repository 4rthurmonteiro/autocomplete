import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pub_api_client/pub_api_client.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pubClient = context.read<PubClient>();

    return SafeArea(
      child: Scaffold(
        body: Autocomplete<PackageResult>(
          optionsBuilder: (value) async {
            if (value.text.length > 1) {
              final result = await pubClient.search(
                value.text,
              );

              if (result.packages.length > 5) {
                return result.packages.sublist(0, 4);
              }

              return result.packages;
            }

            return [];
          },
          displayStringForOption: (packageResult) => packageResult.package,
          onSelected: (packageResult) => GoRouter.of(context).go(
            '/details',
            extra: packageResult,
          ),
        ),
      ),
    );
  }
}
