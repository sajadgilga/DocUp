import 'package:Neuronio/utils/DateTimeService.dart';

enum NeuronioClinicServiceType { MultipleChoiceTest, DoctorsList, Game }

class NeuronioServiceItem {
  final String title;
  final String iconAddress;
  final String iconURL;
  final NeuronioClinicServiceType serviceType;
  final String responseDateTime;
  final Function() onTap;
  final bool enable;

  String get responseNormalTime {
    return responseDateTime != null
        ? DateTimeService.normalizeDateAndTime(responseDateTime,
            withLabel: false)
        : null;
  }

  NeuronioServiceItem(this.title, this.iconAddress, this.iconURL,
      this.serviceType, this.onTap, this.enable,
      {this.responseDateTime});

  factory NeuronioServiceItem.empty() {
    return NeuronioServiceItem(null, null, null, null, null, false);
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
