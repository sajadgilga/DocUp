import 'package:docup/models/BankData.dart';
import 'package:docup/models/SearchResult.dart';
import 'package:docup/networking/ApiProvider.dart';

class UtilRepository {
  final ApiProvider _provider = ApiProvider();

  Future<BankData> getBankData(String accountNumber) async {
    final response = await _provider.get('api/bank?code=${accountNumber}');

    return BankData.fromJson(response['results'][0]);
  }

}
