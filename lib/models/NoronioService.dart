enum NoronioClinicServiceType { MultipleChoiceTest, DoctorsList, Game }

class NoronioService {
  final String title;
  final String iconAddress;
  final String iconURL;
  final NoronioClinicServiceType serviceType;
  final Function() onTap;
  final bool enable;

  NoronioService(this.title, this.iconAddress, this.iconURL, this.serviceType,
      this.onTap, this.enable);

  factory NoronioService.empty() {
    return NoronioService(null, null, null, null, null, false);
  }

  bool get isEmpty {
    if (title == null &&
        iconAddress == null &&
        iconURL == null &&
        serviceType == null &&
        onTap == null &&
        enable == false) {
      return true;
    }
    return false;
  }
}