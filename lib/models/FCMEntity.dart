class RegisterDeviceResponse {
  int id;
  String name;
  String registrationId;
  String deviceId;
  bool active;
  String dateCreated;
  String type;

  RegisterDeviceResponse(
      {this.id,
      this.name,
      this.registrationId,
      this.deviceId,
      this.active,
      this.dateCreated,
      this.type});

  RegisterDeviceResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    registrationId = json['registration_id'];
    deviceId = json['device_id'];
    active = json['active'];
    dateCreated = json['date_created'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['registration_id'] = this.registrationId;
    data['device_id'] = this.deviceId;
    data['active'] = this.active;
    data['date_created'] = this.dateCreated;
    data['type'] = this.type;
    return data;
  }
}
