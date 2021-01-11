import 'package:docup/models/BankData.dart';
import 'package:docup/models/SearchResult.dart';
import 'package:docup/networking/ApiProvider.dart';
import 'package:docup/utils/Utils.dart';

class UtilRepository {
  final ApiProvider _provider = ApiProvider();

  Future<BankData> getBankData(String accountNumber) async {
    final response = await _provider.get('api/bank?code=${accountNumber}');

    return BankData.fromJson(response['results'].length==1?response['results'][0]:{});
  }

  Future<int> getLatestAppBuildNumber() async {
    final response = await _provider.get('api/get-version');

    return intPossible(response['version']);
  }
}
