import 'dart:io';

import 'package:dio/dio.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/widgets/UploadSlider.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';

class FileEntityUser {
  String firstName;
  String lastName;
  int _type;

  /// possible null value from dirty data
  FileEntityUser.fromJson(Map<String, dynamic> json) {
    _type = intPossible(json['type']);
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  String get fullName {
    return (firstName ?? "") + " " + (lastName ?? "");
  }

  bool get isDoctorOwner {
    if (_type == 1) {
      return true;
    }
    return false;
  }

  bool get isPatientOwner {
    if (_type == 0) {
      return true;
    }
    return false;
  }
}

class FileEntity {
  int id;
  int parent;
  String title;
  String description;
  DateTime created_date;
  String fileURL;
  File file;
  String filePath;
  String base64;
  String extension;
  FileEntityUser user;

  FileEntity(
      {this.file,
      this.title,
      this.description,
      this.base64,
      this.filePath,
      this.fileURL,
      this.extension});

  FormData toFormData() {
    FormData data = FormData.fromMap({
      "title": title,
      "description": description,
      "file": MultipartFile.fromFile(filePath)
    });
    return data;
  }

  Map<String, dynamic> toJson() {
    Map json = Map<String, dynamic>();
    json['title'] = title;
    json['description'] = description;
    if (file != null)
      json['file'] = "data:file/" +
          AllowedFile.getFormatFromFilePath(file.path) +
          ";base64," +
          base64;

    return json;
  }

  FileEntity.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    if (json.containsKey('title')) title = utf8IfPossible(json['title']);
    if (json.containsKey('description'))
      description = utf8IfPossible(json['description']);
    if (json.containsKey('file')) fileURL = json['file'];
    if (json.containsKey('created_at'))
      created_date = (json['created_at'] != null
          ? DateTimeService.getDateTimeFromStandardString(json['created_at'])
          : null);
    if (json.containsKey('parent')) parent = json['parent'];
    if (json.containsKey('extension'))
      extension = json['extension'].toString().replaceAll(".", "");
    if (json.containsKey("user") && json['user'] != null) {
      user = FileEntityUser.fromJson(json['user']);
    }
  }

  Image get image {
    if (AllowedFile.getFileType(extension) == AllowedFileType.image) {
      if (file != null) {
        return Image.file(file);
      }
      if (fileURL != null) {
        return Image.network(fileURL);
      }
    }
    return null;
  }

  AllowedFileType get fileType {
    extension = extension ??
        AllowedFile.getFormatFromFilePath(file.path) ??
        AllowedFile.getFormatFromFilePath(fileURL);
    return AllowedFile.getFileType(extension);
  }

  Widget get defaultFileWidget {
    if (file == null) {
      if (fileURL != null) {
        if (fileType == AllowedFileType.image) {
          return Image.network(fileURL);
        } else {
          return Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.picture_as_pdf,
                size: 80,
                color: IColors.red,
              ),
            ),
          );
        }
      } else {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.text_fields,
              size: 80,
              color: IColors.themeColor,
            ),
          ),
        );
      }
    } else if (fileType == AllowedFileType.image) {
      return Image.file(file);
    } else if (AllowedFile.getFileType(
            AllowedFile.getFormatFromFilePath(file.path)) ==
        AllowedFileType.doc) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            Icons.picture_as_pdf,
            size: 80,
            color: IColors.red,
          ),
        ),
      );
    }
    return null;
  }
}
