import 'dart:async';

import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/networking/Response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'AutoText.dart';

class InPlaceEditableText extends StatefulWidget {
  final String title;
  String text;
  final double textFieldWidth;
  final TextInputType inputType;
  final double fontSize;
  final Function() onSaveTap;
  final TextEditingController controller;
  final bool enable;
  final Bloc bloc;

  InPlaceEditableText(this.title, this.text, this.controller,
      {Key key,
      this.textFieldWidth = 100,
      this.inputType,
      this.fontSize = 16,
      this.onSaveTap,
      this.bloc,
      this.enable = false})
      : super(key: key);

  @override
  InPlaceEditableTextState createState() => InPlaceEditableTextState();
}

class InPlaceEditableTextState extends State<InPlaceEditableText> {
  int status = 0;
  StreamSubscription streamSubscription;

  /// 0 for done, 1 for need to save, 2 for waiting, 3 for error

  @override
  void initState() {
    widget.controller.text = widget.text;
    super.initState();
    if (!widget.enable) {
      if (widget.bloc is PatientBloc) {
        streamSubscription = (widget.bloc as PatientBloc).dataStream.listen((response) {
          handleResponse(response);
        });
      }
    }
  }

  void handleResponse(response) {
    switch (response.status) {
      case Status.LOADING:
        setState(() {
          status = 2;
        });
        break;
      case Status.ERROR:
        setState(() {
          status = 3;
        });
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            status = 1;
          });
        });
        break;
      case Status.COMPLETED:
        widget.text = widget.controller.text;
        setState(() {
          status = 0;
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightFor(),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: widget.textFieldWidth,
            child: widget.enable
                ? AutoText(
                    widget.text,
                    fontSize: widget.fontSize,
                    maxLines: 1,
                  )
                : TextFormField(
                    controller: widget.controller,
                    style: TextStyle(
                        fontSize: widget.fontSize,
                        color: status == 3 ? IColors.red : IColors.black),
                    expands: false,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    decoration: InputDecoration(border: InputBorder.none),
                    keyboardType: widget.inputType,
                    onChanged: (c) {
                      if (c != widget.text) {
                        setState(() {
                          status = 1;
                        });
                      } else {
                        setState(() {
                          status = 0;
                        });
                      }
                    },
                  ),
          ),
          Text(
            widget.title + ": ",
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: widget.fontSize),
          ),
          if (status == 1 || status==3)
            GestureDetector(
              onTap: widget.onSaveTap,
              child: Container(
                padding: EdgeInsets.only(left: 10),
                width: 30,
                height: 30,
                child: Icon(
                  Icons.done,
                  size: 20,
                  color: IColors.themeColor,
                ),
              ),
            )
          else
            status == 0
                ? Container(
                    padding: EdgeInsets.only(left: 10),
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: widget.enable ? IColors.darkGrey : IColors.black,
                    ),
                  )
                : Container(
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    width: 30,
                    height: 30,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircleAvatar(
                        backgroundColor: Color.fromARGB(0, 0, 0, 0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(IColors.themeColor),
                        ),
                      ),
                    ),
                  )
        ],
      ),
    );
  }

  @override
  void dispose(){
    streamSubscription.cancel();
    super.dispose();
  }
}
