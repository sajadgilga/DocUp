class PayirResponseEntity {
  final int status;
  final String token;

  PayirResponseEntity({this.status, this.token});

  factory PayirResponseEntity.fromJson(Map<String, dynamic> json) {
    return PayirResponseEntity(
      status: json['status'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['token'] = this.token;
    return data;
  }
}

class HamtaResponseEntity {
  bool ok;
  String paymentUrl;
  String error;

  HamtaResponseEntity({this.ok, this.paymentUrl,this.error});

  HamtaResponseEntity.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    if(ok){
      paymentUrl = json['result']['payment_url'];
    }else{
      error = json['error'];
    }
  }
}
