import 'package:docup/models/Panel.dart';
import 'package:docup/networking/ApiProvider.dart';

class PanelRepository {
  ApiProvider _provider = ApiProvider();

  Future<List<Panel>> getAllPanelsOfMine() async {
    final response = await _provider.get('api/panels/');
    return PanelResponseEntity.fromJson(response).panels;
  }
}
