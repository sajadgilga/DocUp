import 'package:docup/models/SearchResult.dart';
import 'package:docup/networking/ApiProvider.dart';

class SearchRepository {
  final ApiProvider _provider = ApiProvider();

  Future<SearchResult> searchDoctor(searchParam) async {
    final response =
        await _provider.get('api/search/doctors?query=$searchParam');
    return SearchResult.fromJson(response, true);
  }

  Future<SearchResult> searchPatient(searchParam) async {
    final response =
        await _provider.get('api/search/patients-list?query=$searchParam');
    return SearchResult.fromJson(response, false);
  }

  Future<SearchResult> searchPatientRequests(searchParam) async {
    final response =
        await _provider.get('api/search/patients-list?query=$searchParam&status=0,1');
    return SearchResult.fromJson(response, false);
  }

  Future<SearchResult> searchCount(param) async {
    final response =
    await _provider.get('api/search/patients-list?query=$param&status=0,1&page=0');
    return SearchResult.fromJson(response, false);
  }
}
