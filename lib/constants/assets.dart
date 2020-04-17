import 'package:docup/ui/start/RoleType.dart';

class Assets {
  static final String docUpPatientIcon = '';
  static final String docUpDoctorIcon = '';
  static final String docUpClinicIcon = '';
  static final String panelListIcon = 'assets/panelMenu.png';
  static final String searchIcon = 'assets/search.svg';
  static final String onCallMedicalIcon = "assets/onCallIcon.svg";
  static final String patientLoginIcon = "assets/team.svg";
  static final String doctorLoginIcon = "assets/doctor.svg";
  static final String clinicLoginIcon = "assets/doctor.svg";
  static final String homeBackground = 'assets/backgroundHome.png';
  static final String doctorAvatar = 'assets/doctorAvatar.svg';
  static final String calendarCheck = 'assets/calendarCheck.svg';
  static String docUpIcon = docUpPatientIcon;

  static void changeIcons(RoleType roleType) {
    switch (roleType) {
      case RoleType.PATIENT:
        docUpIcon = docUpPatientIcon;
        break;
      case RoleType.CLINIC:
        docUpIcon = docUpClinicIcon;
        break;
      case RoleType.DOCTOR:
        docUpIcon = docUpDoctorIcon;
    }
  }
}
