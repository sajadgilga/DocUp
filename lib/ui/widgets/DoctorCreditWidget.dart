import 'package:flutter/cupertino.dart';

class DoctorCreditWidget extends StatefulWidget{
  @override
  _DoctorCreditWidgetState createState() => _DoctorCreditWidgetState();

}

class _DoctorCreditWidgetState extends State<DoctorCreditWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Text("اعتبار حساب"),
    );
  }

}