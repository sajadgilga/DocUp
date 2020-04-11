class TicketEntity {
  int id;
  String createdDate;
  String modifiedDate;
  bool enabled;
  String doctorMessage;
  String title;
  String patientMessage;
  int status;
  int doctor;
  int patient;
  String panel;

  TicketEntity(
      {this.id,
        this.createdDate,
        this.modifiedDate,
        this.enabled,
        this.doctorMessage,
        this.title,
        this.patientMessage,
        this.status,
        this.doctor,
        this.patient,
        this.panel});

  TicketEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    enabled = json['enabled'];
    doctorMessage = json['doctor_message'];
    title = json['title'];
    patientMessage = json['patient_message'];
    status = json['status'];
    doctor = json['doctor'];
    patient = json['patient'];
    panel = json['panel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
    data['enabled'] = this.enabled;
    data['doctor_message'] = this.doctorMessage;
    data['title'] = this.title;
    data['patient_message'] = this.patientMessage;
    data['status'] = this.status;
    data['doctor'] = this.doctor;
    data['patient'] = this.patient;
    data['panel'] = this.panel;
    return data;
  }
}