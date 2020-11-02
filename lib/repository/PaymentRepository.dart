import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/PayResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';
import 'package:docup/networking/Constants.dart';

class PaymentRepository {
  ApiProvider _provider = ApiProvider();

  Future<PayResponseEntity> sendDataToPay(String mobile, int amount) async {
    final response =
        await _provider.postWithBaseUrl("https://pay.ir/", "pg/send", body: {
      "api": PAY_IR_API_KEY,
      "amount": amount,
      "redirect": "https://service.docup.ir/payment/transaction-call-back",
      "mobile": mobile
    });
    return PayResponseEntity.fromJson(response);
  }

}
