import 'package:docup/models/Picture.dart';
import 'package:docup/networking/ApiProvider.dart';

class PictureRepository {
  ApiProvider _provider = ApiProvider();

  Future<Picture> uploadPicture(
      Picture picture, String listId) async {
    final response = await _provider.postDio('/api/create-image/$listId',
        data: picture.toFormData());
    return Picture.fromJson(response);
  }
}
