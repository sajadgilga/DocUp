import 'package:Neuronio/networking/ApiProvider.dart';
import 'package:Neuronio/utils/CrossPlatformFilePicker.dart';
import 'package:Neuronio/utils/DateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum MessageState { unsent, sent, delivered, failed }
enum MessageType { Text, Image, File, Voice }

class ChatMessage {
  int id;

  int type;

  ////
  DateTime createdDate;
  String modifiedDate;
  bool enabled;
  String message;
  int direction;
  String fileLink;
  bool isRead;
  int panelId;

  /// for upload
  CustomFile file;

  MessageState state;
  bool fromMe = true;

  ChatMessage(
      {this.message,
      this.direction,
      this.fileLink,
      this.file,
      this.fromMe,
      this.createdDate});

  MessageType get messageType {
    if (type == 0) {
      /// text
      return MessageType.Text;
    } else if (type == 1) {
      /// image
      return MessageType.Image;
    } else if (type == 2) {
      /// voice
      return MessageType.File;
    } else if (type == 3) {
      /// video
      return MessageType.File;
    } else if (type == 4) {
      /// pdf
      return MessageType.File;
    }
    return MessageType.File;
  }

  int updateTypeFromFile() {
    if (file != null) {
      switch (file.fileType) {
        case AllowedFileType.image:
          type = 1;
          break;
        case AllowedFileType.pdf:
          type = 4;
          break;
        case AllowedFileType.video:
          type = 3;
          break;
      }
    } else {
      type = 0;
    }
    return type;
  }

  AllowedFileType get fileType {
    if (messageType != MessageType.Text) {
      return file?.fileType ??
          AllowedFile.getFileType(AllowedFile.getFormatFromFilePath(fileLink));
    }
    return null;
  }

  Widget get fileIcon {
    switch (messageType) {
      case MessageType.Text:
        return null;
      case MessageType.Image:
        return Icon(Icons.image);
      case MessageType.File:
        if (fileType == AllowedFileType.image) {
          return Icon(Icons.image);
        } else if (fileType == AllowedFileType.video) {
          return Icon(Icons.video_collection);
        } else if (fileType == AllowedFileType.pdf) {
          return Icon(Icons.picture_as_pdf);
        }
        return null;
      case MessageType.Voice:
        return Icon(Icons.multitrack_audio);
      default:
        return null;
    }
  }

  ChatMessage.fromJson(Map<String, dynamic> json, bool isPatient) {
    id = json['id'];
    if (json.containsKey('created_date')) {
      createdDate =
          DateTimeService.getDateTimeFromStandardString(json['created_date']);
      createdDate = createdDate.add(Duration(hours: 3, minutes: 30));
    } else {
      createdDate = DateTimeService.getCurrentDateTime();
    }

    if (json.containsKey('modified_date')) modifiedDate = json['modified_date'];
    if (json.containsKey('enabled')) enabled = json['enabled'];
    direction = json['direction'];
    fromMe =
        (isPatient && (direction == 0)) || (!isPatient && (direction == 1));
    isRead = json['is_read'];
    panelId = json['panel'];

    type = json['type'];
    message = json['message'];

    /// TODO host should be added from back end
    if (json.containsKey('file') && json['file'] != null) {
      String url = json['file'];
      if (url.startsWith("http")) {
        /// it contain host
        fileLink = json['file'];
      } else {
        fileLink = ApiProvider.Host + json['file'];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (id != null) {
      data['id'] = this.id;
    }
    data['message'] = message;
    if (file != null) {
      if (file != null)
        data['file'] =
            "data:file/" + file.extension + ";base64," + file.convertToBase64;
    }
    if (fileLink != null) {
      data['fileLink'] = fileLink;
    }
    // data['direction'] = direction;

    data['type'] = type ?? updateTypeFromFile();

    return data;
  }
}
