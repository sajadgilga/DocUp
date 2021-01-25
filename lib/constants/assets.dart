import 'package:Neuronio/ui/start/RoleType.dart';

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
  static final String logoRectangle = 'assets/logoTransparentNeuronio.png';
  static final String logoCircle = 'assets/logoCircle.png';
  static final String logoTransparent = 'assets/logoTransparentNeuronio.png';
  static final String profileIcon = 'assets/profileIcon.svg';
  static final String servicesIcon = 'assets/servicesIcon.svg';
  static final String panelIcon = 'assets/panelIcon.svg';

  static final String noronioServiceDoctorList =
      "assets/noronioClinic/doctor (1)@2x.png";
  static final String noronioServiceBrainTest =
      "assets/noronioClinic/brain@2x.png";
  static final String noronioServiceGame =
      "assets/noronioClinic/mobile-game@2x.png";

  static final String homeNoronioClinic = "assets/home/Layer 2@2x.png";
  static final String homeVideos = "assets/home/Layer 2_2@2x.png";
  static final String homePresentVisit =
      "assets/home/video-conference_2@3x.png";
  static final String homeVirtualVisit = "assets/home/video-conference@3x.png";
  static final String homeVisitRequest = "assets/home/request@3x.png";

  static final String accountTelegramIcon = "assets/account/logo (1)@3x.png";
  static final String accountWhatsAppIcon =
      "assets/account/brands-and-logotypes@3x.png";

  static final String panelMyDoctorIcon =
      "assets/panel/Icon awesome-user-md@2x.png";
  static final String panelDoctorDialogDoctorIcon =
      "assets/panel/doctor@3x.png";
  static final String panelDoctorDialogPatientIcon =
      "assets/panel/patient@3x.png";
  static final String panelDoctorDialogAppointmentIcon =
      "assets/panel/appointment@3x.png";
  static final String apiCallError =
      "assets/Group 2910.svg";

  static final String introPage1 = "assets/img1.png";
  static final String introPage2 = "assets/img2.png";
  static final String introPage3 = "assets/img3.png";

  static final String waitFroCodePatient = "assets/startPage/Group 1851.png";
  static final String waitForCodeDoctor = "assets/startPage/Group 1850.png";

  static final String visitListDoctorIcon1 = "assets/visitLists/doctor_4@3x.png";
  static final String patientDetailFilesIcon = "assets/visitLists/file@2x.png";

  static final String fileEntityPatientIcon = "assets/panel/patient.png";
  static final String fileEntityDoctorIcon = "assets/panel/doctor.png";

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
