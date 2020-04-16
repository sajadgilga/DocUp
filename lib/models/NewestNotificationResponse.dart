import 'Medicine.dart';
import 'Notification.dart';

class NewestNotificationResponse {
  int newestEventsCounts;
  int newestDrugsCounts;
  List<Medicine> newestDrugs;
  List<Notification> newestEvents;

  NewestNotificationResponse.fromJson(Map<String, dynamic> json) {
    newestEventsCounts = json['newest_events_counts'];
    newestDrugsCounts = json['newest_drugs_counts'];
    newestDrugs = [];
    json['newest_drugs'].forEach((drug) => newestDrugs.add(Medicine.fromJson(drug)));
    newestEvents = [];
        json['newest_events'].forEach((event) => newestEvents.add(Notification.fromJson(event)));
  }
}
