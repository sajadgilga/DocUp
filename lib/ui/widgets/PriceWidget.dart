import 'package:Neuronio/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';

class PriceWidget extends StatefulWidget {
  final String title;
  final TextEditingController priceController;

  PriceWidget({this.title, this.priceController});

  @override
  _PriceWidgetState createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AutoText("تومان", style: TextStyle(fontSize: 16)),
        Container(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: TextField(
                expands: false,
                controller: widget.priceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                style: TextStyle(
                    fontSize: 17,
                    color: IColors.themeColor,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        AutoText(widget.title, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
