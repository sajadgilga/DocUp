import 'package:docup/models/Panel.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/networking/ApiProvider.dart';

class FileRepository {
  ApiProvider _provider = ApiProvider();

  Future<FileEntity> uploadFile(FileEntity file, int listId) async {
    var data = file.toJson();
    final response = await _provider.post('api/create-file/$listId/',
        body: data);
    return FileEntity.fromJson(response);
  }

  Future<PanelSection> get(int listId) async {
    final response = await _provider.get('api/retrieve-file-list/$listId',
        utf8Support: true);
    return PanelSection.fromJson(response);
  }
}
