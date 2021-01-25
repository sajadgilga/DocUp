import 'package:Neuronio/models/BankData.dart';
import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class UtilRepository {
  final ApiProvider _provider = ApiProvider();

  Future<BankData> getBankData(String accountNumber) async {
    final response = await _provider.get('api/bank?code=${accountNumber}');

    return BankData.fromJson(response['results'].length==1?response['results'][0]:{});
  }

}
