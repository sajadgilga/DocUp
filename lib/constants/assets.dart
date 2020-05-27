import 'package:DocUp/ui/start/RoleType.dart';

class Assets {
  static final String DocUpPatientIcon = 'assets/DocUpHomePatient.svg';
  static final String DocUpDoctorIcon = 'assets/DocUpHomeDoctor.svg';
  static final String DocUpClinicIcon = '';
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

  static String DocUpIcon = DocUpPatientIcon;

  static void changeIcons(RoleType roleType) {
    switch (roleType) {
      case RoleType.PATIENT:
        DocUpIcon = DocUpPatientIcon;
        break;
      case RoleType.CLINIC:
        DocUpIcon = DocUpClinicIcon;
        break;
      case RoleType.DOCTOR:
        DocUpIcon = DocUpDoctorIcon;
    }
    DocUpIcon = logoCircle;
  }
}
