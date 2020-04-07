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
      switch(this){
        case RoleType.PATIENT:
          return "assets/team.svg";
        case RoleType.DOCTOR:
          return "assets/doctor.svg";
        case RoleType.CLINIC:
          return "assets/doctor.svg";
        default:
          return null;
      }
    }

}