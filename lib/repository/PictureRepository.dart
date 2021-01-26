import 'package:Neuronio/blocs/FileBloc.dart';
import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/models/Picture.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class FileRepository {
  ApiProvider _provider = ApiProvider();

  Future<FileEntity> uploadFile(FileEntity file, int listId,int partnerId) async {
    var data = file.toJson();
    final response =
        await _provider.post('api/create-file/$listId/?partner_id=$partnerId', body: data);
    return FileEntity.fromJson(response);
  }

  Future<FileResponseDelete> deleteFile(int fileId, int listId) async {
    final response = await _provider.delete(
      'api/delete-file/$fileId/',
    );
    return FileResponseDelete.fromJson(response);
  }

  Future<PanelSection> get(int listId) async {
    final response = await _provider.get('api/retrieve-file-list/$listId',
        utf8Support: true);
    return PanelSection.fromJson(response);
  }
}
