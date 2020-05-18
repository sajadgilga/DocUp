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
  String base64;

  PictureEntity({this.picture,
    this.title,
    this.description,
    this.base64,
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

  Map<String, dynamic> toJson() {
    Map json = Map<String, dynamic>();
    json['title'] = title;
    json['description'] = description;
    json['image'] = base64;
    return json;
  }

  PictureEntity.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    if (json.containsKey('title')) title = json['title'];
    if (json.containsKey('description')) description = json['description'];
    if (json.containsKey('image')) imageURL = json['image'];
    if (json.containsKey('created_at')) created_date =
    (json['created_at'] != null ? DateTime.parse(json['created_at']) : null);
    if (json.containsKey('parent')) parent = json['parent'];
  }

  Image get image {
    return (picture == null
        ? (imageURL == null ? null : NetworkImage(imageURL))
        : picture);
  }
}
