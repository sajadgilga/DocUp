import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Picture {
  int id;
  int parent;
  String title;
  String description;
  String created_date;
  String imageURL;
  Image picture;
  String imagePath;

  Picture(
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
  }

  Picture.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    imageURL = json['image'];
    created_date = json['created_at'];
    parent = json['parent'];
  }

  Image get image {
    return (picture == null
        ? (imageURL == null ? null : NetworkImage(imageURL))
        : picture);
  }
}
