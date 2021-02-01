import 'dart:convert';

import 'package:Neuronio/models/PayResponseEntity.dart';
import 'package:Neuronio/networking/ApiProvider.dart';
import 'package:Neuronio/networking/Constants.dart';
import 'package:Neuronio/utils/Crypto.dart';

class PaymentRepository {
  ApiProvider _provider = ApiProvider();

  Future<PayirResponseEntity> sendDataToPay(String mobile, int amount) async {
    final response =
        await _provider.postWithBaseUrl("https://pay.ir/", "pg/send", body: {
      "api": PAY_IR_API_KEY,
      "amount": amount,
      "redirect": "https://service.docup.ir/payment/transaction-call-back",
      "mobile": mobile
    });
    return PayirResponseEntity.fromJson(response);
  }

  Future<HamtaResponseEntity> sendDataToHamta(
      int type, String mobile, int amount,
      {Map<String, dynamic> extraCallBackParams}) async {
    Map<String, dynamic> callBackParameters = extraCallBackParams ?? {};
    callBackParameters['amount'] = amount;
    callBackParameters['type'] = type;
    Map<String, dynamic> params = {
      "api_key": HAMTA_IR_API_KEY,
      "reference": CryptoService.generateRandomString(length: 20),
      "amount_irr": amount,
      "callback_url":
          "https://service.docup.ir/payment/transaction-call-back/${CryptoService.codeWithSHA256(json.encode(callBackParameters))}/",
      "pay_mobile": mobile
    };
    String paramString = ApiProvider.getURLParametersString(params);
    final response = await _provider.getWithBaseUrl(
      "https://webpay.bahamta.com/api/create_request?" + paramString,
    );
    return HamtaResponseEntity.fromJson(response);
  }
}
