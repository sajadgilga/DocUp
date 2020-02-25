import 'ChatMessage.dart';
import 'package:flutter/material.dart';

class Patient {
  final String name;
  final String location;
  final String speciality;
  final Image image;

  Patient(this.name, this.speciality, this.location, this.image);
}
