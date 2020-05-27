import 'package:bloc/bloc.dart';
import 'package:DocUp/models/PayResponseEntity.dart';
import 'package:DocUp/repository/PaymentRepository.dart';
import 'package:flutter/cupertino.dart';

class CreditBloc extends Bloc<CreditEvent, CreditState> {
  PaymentRepository _repository = PaymentRepository();

  @override
  get initialState => AddCreditLoading();

  Stream<CreditState> _addCredit(String mobile, int amount) async* {
    yield AddCreditLoading();
    try {
      final PayResponseEntity result =
          await _repository.sendDataToPay(mobile, amount);
      yield AddCreditLoaded(result: result);
    } catch (e) {
      yield AddCreditError();
    }
  }

  @override
  Stream<CreditState> mapEventToState(event) async* {
    if (event is AddCredit) {
      yield* _addCredit(event.mobile, event.amount);
    }
  }
}

// events
abstract class CreditEvent {}

class AddCredit extends CreditEvent {
  final String mobile;
  final int amount;

  AddCredit({@required this.mobile, this.amount});
}

// states
class CreditState {
  PayResponseEntity result;

  CreditState({this.result});
}

class AddCreditError extends CreditState {}

class AddCreditLoaded extends CreditState {
  AddCreditLoaded({result}) : super(result: result);
}

class AddCreditLoading extends CreditState {}
