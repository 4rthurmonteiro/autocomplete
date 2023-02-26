import 'package:pub_api_client/pub_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStoragePersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  Future<List<PackageResult>> getPackageResultHistory() async {
    final prefs = await instanceFuture;

    final packagesString = prefs.getStringList('packageList');

    if (packagesString == null) {
      return [];
    }

    return packagesString.map((e) => _decode(e)).toList();

    // return _decode(packagesString);
  }

  Future<void> fetchPackageResults(
    PackageResult packageResult,
  ) async {
    final history = await getPackageResultHistory();

    final containsIndex = history.indexOf(packageResult);
    if (containsIndex > -1) {
      history.removeAt(containsIndex);
    }

    history.add(
      packageResult,
    );

    final historyToFetch =
        (history.length > 4 ? history.sublist(0, 5) : history)
            .reversed
            .toList();

    final prefs = await instanceFuture;

    await prefs.setStringList(
      'packageList',
      historyToFetch
          .map(
            (e) => _encode(
              e,
            ),
          )
          .toList(),
    );
  }

  String _encode(PackageResult packageResult) => json.encode(
        packageResult.toMap(),
      );

  // String _encode(List<PackageResult> packageResults) => json.encode(
  //       packageResults
  //           .map<Map<String, dynamic>>(
  //             (packageResult) => packageResult.toMap(),
  //           )
  //           .toList(),
  //     );

  List<PackageResult> _decodeToList(String packageResults) =>
      (json.decode(packageResults) as List<dynamic>)
          .map<PackageResult>(
            (item) => PackageResult.fromMap(
              item,
            ),
          )
          .toList();

  PackageResult _decode(String packageResultString) => PackageResult.fromMap(
        json.decode(
          packageResultString,
        ),
      );
}
