import 'Panel.dart';
import 'UserEntity.dart';
import 'VisitResponseEntity.dart';

class PatientEntity extends UserEntity {
  PanelSection documents;
  int status;
  double height;
  double weight;
  List<VisitItem> visits;

  PatientEntity(
      {this.documents, this.height, this.weight, user, id, panels, vid})
      : super(user: user, id: id, panels: panels, vid: vid);

  PatientEntity.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      if (json.containsKey('user')) {
        if (json['user'].containsKey('user'))
          user = json['user']['user'] != null
              ? User.fromJson(json['user']['user'])
              : null;
        else
          user = json['user'] != null ? User.fromJson(json['user']) : null;
      }
      if (json.containsKey('status')) status = json['status'];
      if (json.containsKey('documents'))
        documents = json['documents'] != null
            ? PanelSection.fromJson(json['documents'])
            : null;
      if (json.containsKey('panels')) {
        panels = [];
        if (json['panels'].length != 0) {
          json['panels'].forEach((panel) {
            if (panel == null) return;
            panels.add(Panel.fromJson(panel));
            panelMap[panels.last.id] = panels.last;
          });
        }
      }

      if (json.containsKey('height')) {
        height = double.parse(json['height'].toString());
      }
      if (json.containsKey('weight')) {
        weight = double.parse(json['weight'].toString());
      }
      if (json.containsKey('visits')) {
        visits = [];
        (json['visits'] as List<dynamic>).forEach((element) {
          visits.add(VisitItem.fromJson(element));
        });
      }
    } catch (_) {
      // TODO
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (id != null) data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (height != null) {
      data['height'] = height;
    }
    if (weight != null) {
      data['weight'] = weight;
    }
    return data;
  }

  int get vid {
    return super.vid ?? currentPatientVisit?.id;
  }

  VisitItem get currentPatientVisit {
    try {
      DateTime now = DateTime.now();
      for (int i = 0; i < visits?.length; i++) {
        VisitItem visitItem = visits[i];
        DateTime date =
            DateTime.parse(visitItem.requestVisitTime.split("+")[0]);
        if (date.compareTo(now) > 0 && visitItem.status == 0) {
          return visitItem;
        }
      }
    } catch (e) {}

    return null;
  }
}
