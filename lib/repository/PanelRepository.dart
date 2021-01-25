import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class PanelRepository {
  ApiProvider _provider = ApiProvider();

  Future<List<Panel>> getAllPanelsOfMine() async {
    final response = await _provider.get('api/panels/');
    return PanelResponseEntity.fromJson(response).panels;
  }
}
