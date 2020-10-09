import 'Panel.dart';
import 'UserEntity.dart';

class PatientEntity extends UserEntity {
  PanelSection documents;
  int status;

  PatientEntity({this.documents, user, id, panels, vid}): super(user:user, id: id, panels: panels, vid: vid);

  PatientEntity.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      if (json.containsKey('user')) {
        if (json['user'].containsKey('user'))
        user = json['user']['user'] != null ? User.fromJson(json['user']['user']) : null;
        else
        user = json['user'] != null ? User.fromJson(json['user']) : null;

      }
      if (json.containsKey('status'))
        status = json['status'];
      if (json.containsKey('documents'))
        documents = json['documents'] != null
            ? PanelSection.fromJson(json['documents'])
            : null;
      if (!json.containsKey('panels')) return;
      panels = [];
      if (json['panels'].length != 0)
        json['panels'].forEach((panel) {
          if (panel == null)
            return;
          panels.add(Panel.fromJson(panel));
          panelMap[panels.last.id] = panels.last;
        });
    } catch (_) {
      // TODO
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}
