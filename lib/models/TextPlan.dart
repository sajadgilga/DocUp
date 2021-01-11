class TextPlanRemainedTraffic {
  bool success;
  int remainedWords;

  TextPlanRemainedTraffic({this.success, this.remainedWords});

  TextPlanRemainedTraffic.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    /// TODO
    remainedWords = json['remained_words']??json['remained_message'];
  }
}
