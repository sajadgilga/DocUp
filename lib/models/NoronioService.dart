enum NoronioClinicServiceType { MultipleChoiceTest, DoctorsList, Game }



class NoronioServiceItem {
  final String title;
  final String iconAddress;
  final String iconURL;
  final NoronioClinicServiceType serviceType;
  final Function() onTap;
  final bool enable;

  NoronioServiceItem(this.title, this.iconAddress, this.iconURL,
      this.serviceType, this.onTap, this.enable);

  factory NoronioServiceItem.empty() {
    return NoronioServiceItem(null, null, null, null, null, false);
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
