import 'package:flutter/material.dart';
import 'ChatMessage.dart';

class Doctor {
  final String name;
  final String location;
  final String speciality;
  final Image image;
  List<ChatMessage> messages;

  Doctor(this.name, this.speciality, this.location, this.image, this.messages);
}