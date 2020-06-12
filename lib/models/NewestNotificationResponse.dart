import 'Medicine.dart';
import 'Notification.dart';

class NewestNotificationResponse {
  int newestEventsCounts;
  int newestDrugsCounts;
  List<Medicine> newestDrugs;
  List<Notification> newestEvents;

  NewestNotificationResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('newest_events_counts'))
      newestEventsCounts = json['newest_events_counts'];
    else
      newestEventsCounts = 0;
    if (json.containsKey('newest_drugs_counts'))
      newestDrugsCounts = json['newest_drugs_counts'];
    else
      newestDrugsCounts = 0;
    newestDrugs = [];
    if (json.containsKey('newest_drugs')) if (json['newest_drugs'] != null)
      json['newest_drugs']
          .forEach((drug) => newestDrugs.add(Medicine.fromJson(drug)));
    newestEvents = [];
    if (json['newest_events'] != null)
      json['newest_events']
          .forEach((event) => newestEvents.add(Notification.fromJson(event)));
    newestEvents = newestEvents.reversed.toList();
  }
}
