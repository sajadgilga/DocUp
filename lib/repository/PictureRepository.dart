import 'package:DocUp/models/Panel.dart';
import 'package:DocUp/models/Picture.dart';
import 'package:DocUp/networking/ApiProvider.dart';

class PictureRepository {
  ApiProvider _provider = ApiProvider();

  Future<PictureEntity> uploadPicture(PictureEntity picture, int listId) async {
    var data = picture.toJson();
    final response = await _provider.post('api/create-image/$listId/',
        body: data);
    return PictureEntity.fromJson(response);
  }

  Future<PanelSection> get(int listId) async {
    final response = await _provider.get('api/retrieve-image-list/$listId',
        utf8Support: true);
    return PanelSection.fromJson(response);
  }
}
