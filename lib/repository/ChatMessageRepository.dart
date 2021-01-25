import 'package:Neuronio/models/ChatMessage.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class ChatMessageRepository {
  ApiProvider _provider = ApiProvider();

  List<ChatMessage> _getList(json, isPatient) {
    return (json as List).map((message) {
      return ChatMessage.fromJson(message, isPatient);
    }).toList();
  }

  Future<List<ChatMessage>> getMessages(
      {panel, messageId, up, down, size, isPatient}) async {
    var response;
    if (messageId == null)
      response = await _provider.get(
          'api/chat/messages/$panel/?message_id=&up=$up&down=$down&size=$size',
          utf8Support: true);
    else
      response = await _provider.get(
          'api/chat/messages/$panel/?message_id=$messageId&up=$up&down=$down&size=$size',
          utf8Support: true);
    return _getList(response, isPatient);
  }

  Future<String> send({panel, ChatMessage message}) async {
    final response = await _provider.post('api/chat/messages/$panel/',
        body: message.toJson(), withToken: true);
    return '';
  }
}
