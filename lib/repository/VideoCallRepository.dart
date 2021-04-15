import 'package:Neuronio/models/AgoraChannelEntity.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class VideoCallRepository {
  ApiProvider _provider = ApiProvider();

  Future<AgoraChannel> getChannelName(int doctorId, {int visitId}) async {
    String params = "doctor_id=${doctorId.toString()}";
    if (visitId != null) {
      params += "&visit_id=$visitId";
    }
    final response = await _provider.get("api/agora-channel-name/?$params");
    return AgoraChannel.fromJson(response);
  }
}
