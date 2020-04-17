import 'DoctorEntity.dart';
import 'PatientEntity.dart';
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
    panels = [];
    if (json['results'].length != 0)
      json['results'].forEach((panel) => panels.add(Panel.fromJson(panel)));
  }
}

class Panel {
  int id;
  int status;
  int doctorId;
  int patientId;
  List<PanelSection> section;
  List<String> sectionNames;
  String modified_date;
  String created_date;
  PatientEntity patient;
  DoctorEntity doctor;

// TODO: add  List<Visit> visits;

  Panel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      status = json['status'];
      if (json.containsKey('doctor')) doctorId = json['doctor'];
      if (json.containsKey('patient')) patientId = json['patient'];
      modified_date =
      json.containsKey('modified_date') ? json['modified_date'] : null;
      created_date =
      json.containsKey('created_date') ? json['created_date'] : null;
      section = [];
      if (json.containsKey('panel_image_sets')) {
        var sets = json['panel_image_sets'];
        List<Picture> pictures;
        sets.forEach((key, value) {
          pictures = [];
          if (value.length != 0)
            value.forEach((image) => pictures.add(Picture.fromJson(image)));
          section.add(PanelSection(
              id: json['panel_image_list_name_id'][key],
              title: key,
              pictures: pictures));
        });
      }

//    if (sets['disease_images'].length != 0) {
//      pictures = sets['disease_images'].forEach((Map image) => Picture.fromJson(image));
//      PanelSection(id: json['panel_image_list_name_id']['id'])
//      section.add(Picture.fromJson(json['disease_images']));
//    }
//    if (sets['test_results'].length != 0)
//      section.add(Picture.fromJson(json['test_results']));
//    if (sets['prescriptions'].length != 0)
//      section.add(Picture.fromJson(json['prescriptions']));
//    if (sets['cognitive_tests'].length != 0)
//      section.add(Picture.fromJson(json['cognitive_tests']));

      if (json.containsKey('patient_info'))
        patient = PatientEntity.fromJson(json['patient_info']);

      if (json.containsKey('doctor_info'))
        doctor = DoctorEntity.fromJson(json['doctor_info']);
    } catch(_) {
      // TODO
    }
  }
}

class PanelSection {
  int id;
  String title;
  String description;
  List<Picture> pictures;

  PanelSection({this.id, this.title, this.description, this.pictures});

  PanelSection.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('id'))
        id = json['id'];
      if (json.containsKey('title'))
        title = json['title'];
      if (json.containsKey('description'))
        description = json['description'];
      if (json['images'].length == 0)
        pictures = [];
      else {
        pictures =
            json['images'].forEach((Map image) => Picture.fromJson(image));
      }
    } catch (_) {
      // TODO
    }
  }
}
