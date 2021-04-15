enum SocketMessageType { NEW_MESSAGE, TOGGLE_VISIT_TEXT_PLAN }

extension SocketMessageTypeTitle on SocketMessageType {
  get name {
    switch (this) {
      case SocketMessageType.NEW_MESSAGE:
        return "NEW_MESSAGE";
      case SocketMessageType.TOGGLE_VISIT_TEXT_PLAN:
        return "TOGGLE_VISIT_TEXT_PLAN";
    }
  }
}

abstract class SocketRequest {
  final SocketMessageType requestType;

  toJson();

  SocketRequest(this.requestType);
}

class NewMessageSocketRequest extends SocketRequest {
  final int panelId;
  final int messageType;
  final String message;
  final String fileLink;
  final String isMe;
  final int messageId;

  NewMessageSocketRequest(SocketMessageType requestType, this.panelId,
      this.messageType, this.message, this.fileLink, this.isMe, this.messageId)
      : super(requestType);

  toJson() {
    Map<String, dynamic> data = {};
    data['request_type'] = requestType.name;
    data['panel_id'] = panelId;
    data['message'] = message;
    data['type'] = messageType;
    data['file'] = fileLink;
    data['isMe'] = isMe;
    data['message_id'] = messageId;
    return data;
  }
}

class ActivateOrDeactivatePatientTextPlan extends SocketRequest {
  final int panelId;
  final int patientVisitTextPlanId;
  final bool enabled;
  final String time;

  ActivateOrDeactivatePatientTextPlan(SocketMessageType requestType,
      this.panelId, this.patientVisitTextPlanId, this.enabled, this.time)
      : super(requestType);

  toJson() {
    Map<String, dynamic> data = {};
    data['request_type'] = requestType.name;
    data['panel_id'] = panelId;
    data['visit_text_plan_id'] = patientVisitTextPlanId;
    data['enabled'] = enabled;
    data['time'] = time;
    return data;
  }
}
