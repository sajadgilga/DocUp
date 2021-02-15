// import 'dart:html' as html;
import 'dart:io' as io;

import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// TODO web
enum AllowedFileType { image, doc }

class AllowedFile {
  static final List<String> imageFormats = ['jpg', 'jpeg', 'png'];
  static final List<String> docs = ['pdf'];

  static String getFormatFromFilePath(String path) {
    return path.split(".").last.toLowerCase();
  }

  static AllowedFileType getFileType(String format) {
    if (AllowedFile.imageFormats.contains(format)) {
      return AllowedFileType.image;
    } else if (AllowedFile.docs.contains(format)) {
      return AllowedFileType.doc;
    } else {
      return null;
    }
  }
}

class CustomFile {
  AllowedFileType fileType;
  String name;
  String path;
  List<int> fileBits;

  String get extension {
    return AllowedFile.getFormatFromFilePath(path ?? name);
  }

  CustomFile.fromIoFile(io.File file, AllowedFileType fileType) {
    this.fileType = fileType;
    this.name = file.path?.split("/")?.last;
    this.path = file.path;
    this.fileBits = file.readAsBytesSync();
  }

  // CustomFile.fromHtmlFile(
  //     html.File file, AllowedFileType fileType, List<int> fileBits) {
  //   this.fileType = fileType;
  //   this.name = file.name;
  //   this.path = null;
  //   this.fileBits = fileBits;
  // }
}

class CrossPlatformFilePicker {
  static Future<CustomFile> pickCustomImageFile(
      {bool imageCropper = true}) async {
    final _picker = ImagePicker();
    if (CrossPlatformDeviceDetection.isWeb) {
      FilePickerResult result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);

      if (result != null && result.files != null && result.files.length != 0) {
        print(result.files[0].name);
        // return CustomFile.fromHtmlFile(
        //     html.File(result.files[0].bytes, result.files[0].name),
        //     AllowedFileType.image,
        //     result.files[0].bytes);
      } else {
        return null;
      }
    } else {
      var image = await _picker.getImage(source: ImageSource.gallery);
      if (imageCropper) {
        io.File croppedFile = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: IColors.themeColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));
        return CustomFile.fromIoFile(croppedFile, AllowedFileType.image);
      } else {
        return CustomFile.fromIoFile(
            io.File(image.path), AllowedFileType.image);
      }
    }
  }

  static Future<CustomFile> pickCustomFile(List<String> allowedFormats) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: allowedFormats,
        type: FileType.custom);
    if (result != null && result.files != null && result.files.length != 0) {
      AllowedFileType allowedFileType =
          AllowedFile.getFileType(result.files[0].extension);
      if (CrossPlatformDeviceDetection.isWeb) {
        // return CustomFile.fromHtmlFile(
        //     html.File(result.files[0].bytes, result.files[0].name),
        //     allowedFileType,
        //     result.files[0].bytes);
      } else {
        return CustomFile.fromIoFile(
            io.File(result.files[0].path), allowedFileType);
      }
    } else {
      return null;
    }
  }
}
