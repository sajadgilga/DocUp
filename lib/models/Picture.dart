import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PictureEntity {
  int id;
  int parent;
  String title;
  String description;
  DateTime created_date;
  String imageURL;
  Image picture;
  String imagePath;

  PictureEntity(
      {this.picture,
      this.title,
      this.description,
      this.imagePath,
      this.imageURL});

  FormData toFormData() {
    FormData data = FormData.fromMap({
      "title": title,
      "description": description,
      "image": MultipartFile.fromFile(imagePath)
    });
    return data;
  }

  PictureEntity.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    if (json.containsKey('title')) title = json['title'];
    if (json.containsKey('title')) description = json['description'];
    if (json.containsKey('title')) imageURL = json['image'];
    if (json.containsKey('title')) created_date = (json['created_at'] != null?DateTime.parse(json['created_at']): null);
    if (json.containsKey('title')) parent = json['parent'];
  }

  Image get image {
    return (picture == null
        ? (imageURL == null ? null : NetworkImage(imageURL))
        : picture);
  }
}
