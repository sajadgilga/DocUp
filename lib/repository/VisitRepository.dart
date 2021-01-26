import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class VisitRepository {
  ApiProvider _provider = ApiProvider();

  Future<VisitEntity> getCurrentVisit(pId) async {
    final response = await _provider.get('api/visit-related-accepted-nearest/$pId');
    return VisitEntity.fromJson(response);
  }
}
