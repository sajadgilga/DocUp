class BankData {
  String name;
  String logo;
  String number;
  int id;

  BankData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    number = json['number'];
    logo = json['logo'];
  }
}
