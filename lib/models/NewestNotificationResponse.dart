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
    newestDrugs = json['newest_drugs'].map((Map drug) => Medicine.fromJson(drug));
    newestEvents =
        json['newest_events'].map((Map event) => Notification.fromJson(event));
  }
}
