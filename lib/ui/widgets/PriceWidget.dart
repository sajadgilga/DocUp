import 'package:docup/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PriceWidget extends StatefulWidget {
  final String title;
  final String price;

  PriceWidget({this.title, this.price});

  @override
  _PriceWidgetState createState() => _PriceWidgetState();

}

class _PriceWidgetState extends State<PriceWidget>{
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:CrossAxisAlignment.end,
      children: <Widget>[
        Text("تومان", style: TextStyle(fontSize: 16)),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Text(widget.price, style: TextStyle(fontSize: 18, color: IColors.themeColor, fontWeight: FontWeight.bold)),
        ),
        Text(widget.title, style: TextStyle(fontSize: 16)),
      ],
    );
  }

}