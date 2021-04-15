class PatientTracker {
  int all;
  int visitPending;
  int curing;
  int cured;

  PatientTracker(
      {this.all = 1, this.visitPending = 0, this.cured = 0, this.curing = 0});

  PatientTracker.fromJson(Map<String, dynamic> json) {
    all = 1;
    visitPending = 0;
    curing = 0;
    cured = 0;
    if (json.containsKey('all')) all = json['all'];
    if (all == 0) all = 1;
    if (json.containsKey('visit_pending')) visitPending = json['visit_pending'];
    if (json.containsKey('virtual_accepted')) curing = json['virtual_accepted'];
    if (json.containsKey('physical_accepted'))
      cured = json['physical_accepted'];
  }
}
