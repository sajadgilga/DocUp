import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum RoleType {
  PATIENT, DOCTOR
}

extension RoleTypeExtension on RoleType {
    String get name {
      switch(this){
        case RoleType.PATIENT:
          return "سلامت‌جو";
        case RoleType.DOCTOR:
          return "پزشک";
        default:
          return null;
      }
    }

    String get asset {
      switch(this){
        case RoleType.PATIENT:
          return "assets/team.svg";
        case RoleType.DOCTOR:
          return "assets/doctor.svg";
        default:
          return null;
      }
    }

    Color get color {
      switch(this){
        case RoleType.PATIENT:
          return Colors.red;
        case RoleType.DOCTOR:
          return Colors.green;
        default:
          return null;
      }
    }
}