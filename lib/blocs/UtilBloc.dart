import 'dart:async';

import 'package:docup/models/BankData.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/UtilRepository.dart';

class UtilBloc {
  UtilRepository _repository;
  StreamController _utilController;

  StreamSink<Response<BankData>> get bankSink => _utilController.sink;

  Stream<Response<BankData>> get bankStream => _utilController.stream;

  UtilBloc() {
    _utilController = StreamController<Response<BankData>>();
    _repository = UtilRepository();
  }

  getBankData(String accountNumber) async {
    bankSink.add(Response.loading());
    try {
      BankData _response = await _repository.getBankData(accountNumber);
      bankSink.add(Response.completed(_response));
    } catch (e) {
      bankSink.add(Response.error(e));
      print(e);
    }
  }

  dispose() {
    _utilController?.close();
  }
}
