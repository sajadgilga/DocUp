import 'DoctorResponseEntity.dart';
import 'Patient.dart';
import 'Picture.dart';

class PanelResponseEntity {
  int count;
  int next;
  int previous;
  List<Panel> panels;

  PanelResponseEntity.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'].length == 0)
      panels = [];
    else
      panels = json['results'].map((Map panel) => Panel.fromJson(panel));
  }
}

class Panel {
  int id;
  int status;
  int doctorId;
  int patientId;
  List<PanelSection> section;
  String modified_date;
  String created_date;
  Patient patient;
  DoctorEntity doctor;

// TODO: add  List<Visit> visits;

  Panel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    doctorId = json['doctor'];
    modified_date =
        json.containsKey('modified_date') ? json['modified_date'] : null;
    created_date =
        json.containsKey('created_date') ? json['created_date'] : null;
    section = [];
    if (json['disease_images'] != null)
      section.add(PanelSection.fromJson(json['disease_images']));
    if (json['test_results'] != null)
      section.add(PanelSection.fromJson(json['test_results']));
    if (json['prescriptions'] != null)
      section.add(PanelSection.fromJson(json['prescriptions']));

    if (json['patient_info'] != null)
      patient = Patient.fromJson(json['patient_info']);

    if (json['doctor_info'] != null)
      doctor = DoctorEntity.fromJson(json['doctor_info']);
  }
}

class PanelSection {
  int id;
  String title;
  String description;
  List<Picture> pictures;

  PanelSection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    if (json['images'].length == 0)
      pictures = [];
    else {
      pictures = json['images'].map((Map image) => Picture.fromJson(image));
    }
  }
}
