import 'package:DocUp/models/AgoraChannelEntity.dart';
import 'package:DocUp/networking/ApiProvider.dart';

class VideoCallRepository {
  ApiProvider _provider = ApiProvider();

  Future<AgoraChannel> getChannelName(int doctorId) async {
    final response =
        await _provider.get("api/agora-channel-name/?doctor_id=" + doctorId.toString());
    return AgoraChannel.fromJson(response);
  }


}
