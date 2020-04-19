import 'package:docup/models/Panel.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/networking/ApiProvider.dart';

class PictureRepository {
  ApiProvider _provider = ApiProvider();

  Future<PictureEntity> uploadPicture(PictureEntity picture, int listId) async {
    var data = picture.toFormData();
    final response = await _provider.postDio('api/create-image/$listId/',
        data: data);
    return PictureEntity.fromJson(response);
  }

  Future<PanelSection> get(int listId) async {
    final response = await _provider.get('api/retrieve-image-list/$listId',
        utf8Support: true);
    return PanelSection.fromJson(response);
  }
}
