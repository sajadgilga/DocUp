import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/utils/CrossPlatformFilePicker.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/DateTimeService.dart';
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
  String fileURL;
  CustomFile customFile;
  String filePath;
  String base64;
  String extension;
  FileEntityUser user;
  DateTime createdDate;

  FileEntity(
      {this.customFile,
      this.title,
      this.description,
      this.base64,
      this.filePath,
      this.fileURL,
      this.extension});

  Map<String, dynamic> toJson() {
    Map json = Map<String, dynamic>();
    json['title'] = title;
    json['description'] = description;
    if (customFile != null)
      json['file'] = "data:file/" + customFile.extension + ";base64," + base64;

    return json;
  }

  FileEntity.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    if (json.containsKey('title')) title = utf8IfPossible(json['title']);
    if (json.containsKey('description'))
      description = utf8IfPossible(json['description']);
    if (json.containsKey('file')) fileURL = json['file'];
    if (json.containsKey('created_at'))
      createdDate = (json['created_at'] != null
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
      if (customFile != null) {
        return Image.memory(customFile.fileBits);
      }
      if (fileURL != null) {
        return Image.network(fileURL);
      }
    }
    return null;
  }

  AllowedFileType get fileType {
    return customFile?.fileType ??
        AllowedFile.getFileType(extension ??
            AllowedFile.getFormatFromFilePath(filePath ?? fileURL));
  }

  Widget get defaultFileWidget {
    if (customFile == null) {
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
      return Image.memory(customFile.fileBits);
    } else if (customFile.fileType == AllowedFileType.pdf) {
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
