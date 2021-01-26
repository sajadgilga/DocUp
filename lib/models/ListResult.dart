import 'package:Neuronio/models/VisitResponseEntity.dart';

class ListResult {
  int count;
  int next;
  int previous;
  List<VisitEntity> results;

  ListResult.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    results = [];
    if (json['results'].length != 0)
      json['results']
          .forEach((panel) => results.add(VisitEntity.fromJson(panel)));
  }
}
