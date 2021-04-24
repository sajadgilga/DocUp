import 'package:Neuronio/utils/Utils.dart';

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
      json['results'].forEach((panel) {
        if (panel != null) panels.add(Panel.fromJson(panel));
      });
  }
}

class Panel {
  int id;
  int status;
  int doctorId;
  int patientId;
  bool enabled;
  List<PanelSection> section;
  Map<String, PanelSection> sections = {};
  List<String> sectionNames;
  String modifiedDate;
  String createdDate;
  PatientEntity patient;
  DoctorEntity doctor;

// TODO: add  List<Visit> visits;

  Panel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      status = json['status'];
      enabled = true;
      if (json.containsKey('enabled')) enabled = json['enabled'];
      if (json.containsKey('doctor')) doctorId = json['doctor'];
      if (json.containsKey('patient')) patientId = json['patient'];
      modifiedDate =
          json.containsKey('modified_date') ? json['modified_date'] : null;
      createdDate =
          json.containsKey('created_date') ? json['created_date'] : null;
      section = [];
      if (json.containsKey('panel_image_sets')) {
        var sets = json['panel_image_sets'];
        List<FileEntity> pictures;
        sets.forEach((String key, value) {
          pictures = [];
          if (value.length != 0) {
            value.forEach((image) => pictures.add(FileEntity.fromJson(image)));
          }
          section.add(PanelSection(
              id: json['panel_image_list_name_id'][key],
              title: key,
              pictures: pictures));
          sections[key] = section.last;
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
    } catch (e) {
      print(e);
    }
  }

  String get statusDescription {
    switch (status) {
      case 0:
        return "درخواست ویزیت حضوری";
      case 1:
        return "درخواست ویزیت مجازی";
      case 2:
        return "وریفای حضوری";
      case 3:
        return "وریفای مجازی";
      case 4:
        return "درحال درمان حضوری";
      case 5:
        return "در حال درمان مجازی";
      case 6:
        return "درمان شده";
      case 7:
        return "رد شده";
      default:
        return "وضعیت نامشخص";
    }
  }
}

class PanelSection {
  int id;
  String title;
  String description;
  List<FileEntity> pictures;

  PanelSection({this.id, this.title, this.description, this.pictures});

  PanelSection.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('id')) id = json['id'];
      if (json.containsKey('title')) title = utf8IfPossible(json['title']);
      if (json.containsKey('description'))
        description = utf8IfPossible(json['description']);
      pictures = [];
//      if (json['images'].value.length != 0) {
      json['files']
          .forEach((image) => pictures.add(FileEntity.fromJson(image)));
//      }
    } catch (e) {
      print(e);
    }
  }
}
