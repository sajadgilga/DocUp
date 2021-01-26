import 'package:Neuronio/networking/CustomException.dart';

class Response<T> {
  Status status;
  T data;
  Exception error;

  Response.loading() : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.error) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status  \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR }