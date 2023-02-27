import 'package:pub_api_client/pub_api_client.dart';

class PackageDetail {
  final PackageScore score;
  final PubPackage info;

  const PackageDetail({
    required this.score,
    required this.info,
  });
}
