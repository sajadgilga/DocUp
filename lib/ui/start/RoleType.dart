import 'package:docup/constants/assets.dart';

enum RoleType {
  PATIENT, DOCTOR, CLINIC
}

extension RoleTypeExtension on RoleType {
    String get name {
      switch(this){
        case RoleType.PATIENT:
          return "سلامت‌جو";
        case RoleType.DOCTOR:
          return "پزشک";
        case RoleType.DOCTOR:
          return "کلینیک";
        default:
          return null;
      }
    }

    String get asset {
      return Assets.patientLoginIcon;
//      switch(this){
//        case RoleType.PATIENT:
//          return Assets.patientLoginIcon;
//        case RoleType.DOCTOR:
//          return Assets.doctorLoginIcon;
//        case RoleType.CLINIC:
//          return Assets.clinicLoginIcon;
//        default:
//          return null;
//      }
    }

}