import 'package:Neuronio/models/PayResponseEntity.dart';
import 'package:Neuronio/repository/PaymentRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class CreditBloc extends Bloc<CreditEvent, CreditState> {
  PaymentRepository _repository = PaymentRepository();

  @override
  get initialState => AddCreditLoading();

  Stream<CreditState> _addCredit(int type, String mobile, int amount,
      {Map<String, dynamic> extraCallBackParams}) async* {
    yield AddCreditLoading();
    try {
      /// changes to hamta payment
      final HamtaResponseEntity result = await _repository.sendDataToHamta(
          type, mobile, amount,
          extraCallBackParams: extraCallBackParams);
      if (!result.ok) {
        throw Exception(result.error);
      }
      yield AddCreditLoaded(result: result);
    } catch (e) {
      print(e);
      yield AddCreditError();
    }
  }

  @override
  Stream<CreditState> mapEventToState(event) async* {
    if (event is AddCredit) {
      yield* _addCredit(event.type, event.mobile, event.amount);
    }
  }
}

// events
abstract class CreditEvent {}

class AddCreditType{
  static int addCredit = 1;
  static int buyScreeningPlan = 2;
}
class AddCredit extends CreditEvent {
  final int type;
  final String mobile;
  final int amount;

  AddCredit({@required this.type, @required this.mobile, this.amount});
}

// states
class CreditState {
  HamtaResponseEntity result;

  CreditState({this.result});
}

class AddCreditError extends CreditState {}

class AddCreditLoaded extends CreditState {
  AddCreditLoaded({result}) : super(result: result);
}

class AddCreditLoading extends CreditState {}
