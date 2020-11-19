import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docup/ui/widgets/UploadSlider.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';

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
    json['file'] = base64;
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
          ? DateTime.parse(json['created_at'])
          : null);
    if (json.containsKey('parent')) parent = json['parent'];
    if (json.containsKey('extension'))
      extension = json['extension'].toString().replaceAll(".", "");
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

  Widget get defaultFileWidget {
    if (file == null) {
      if (fileURL != null) {
        return Image.network(fileURL);
      }
    } else if (AllowedFile.getFileType(
            AllowedFile.getFormatFromFilePath(file.path)) ==
        AllowedFileType.image) {
      return Image.file(file);
    } else if (AllowedFile.getFileType(
            AllowedFile.getFormatFromFilePath(file.path)) ==
        AllowedFileType.doc) {
      return Icon(
        Icons.insert_drive_file,
        size: 100,
      );
    }
    return null;
  }
}
