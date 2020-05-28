import 'package:docup/ui/start/RoleType.dart';

class Assets {
  static final String docupPatientIcon = 'assets/docupHomePatient.svg';
  static final String docupDoctorIcon = 'assets/docupHomeDoctor.svg';
  static final String docupClinicIcon = '';
  static final String panelListIcon = 'assets/panelMenu.svg';
  static final String searchIcon = 'assets/search.svg';
  static final String onCallMedicalIcon = "assets/onCallIcon.svg";
  static final String patientLoginIcon = "assets/team.svg";
  static final String doctorLoginIcon = "assets/doctor.svg";
  static final String clinicLoginIcon = "assets/doctor.svg";
  static final String homeBackground = 'assets/backgroundHome.png';
  static final String doctorAvatar = 'assets/doctorAvatar.svg';
  static final String calendarCheck = 'assets/calendarCheck.svg';
  static final String clinicPanel = 'assets/clinicPanel.svg';
  static final String emptyAvatar = 'assets/avatar.png';
  static final String logoRectangle = 'assets/logoRec.png';
  static final String logoCircle = 'assets/logoCircle.png';
  static final String logoTransparent = 'assets/logoTransparent.png';

  static String docupIcon = docupPatientIcon;

  static void changeIcons(RoleType roleType) {
    switch (roleType) {
      case RoleType.PATIENT:
        docupIcon = docupPatientIcon;
        break;
      case RoleType.CLINIC:
        docupIcon = docupClinicIcon;
        break;
      case RoleType.DOCTOR:
        docupIcon = docupDoctorIcon;
    }
    docupIcon = logoCircle;
  }
}
