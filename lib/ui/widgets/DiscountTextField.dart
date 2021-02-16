import 'package:Neuronio/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

import 'AutoText.dart';

enum DiscountStats { Null, Loading, Valid, Invalid }

class DiscountTextField extends StatefulWidget {
  /// simpletooltip
  final String simpleToolTipString;
  final bool simpleToolTipFlag;
  final Function() onTooltipTap;
  DiscountStats discountStatus;

  /// discount string
  final TextEditingController textEditingController;
  final Function() onDiscountIconTap;

  DiscountTextField(
      {Key key,
      this.simpleToolTipString,
      this.simpleToolTipFlag,
      this.onTooltipTap,
      this.textEditingController,
      this.discountStatus = DiscountStats.Null,
      this.onDiscountIconTap})
      : super(key: key);

  @override
  _DiscountTextFieldState createState() => _DiscountTextFieldState();
}

class _DiscountTextFieldState extends State<DiscountTextField> {
  Widget disCountPrefixIcon() {
    return GestureDetector(
      onTap: widget.onDiscountIconTap,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: widget.discountStatus == DiscountStats.Null
              ? Icon(Icons.add)
              : (widget.discountStatus == DiscountStats.Loading
                  ? CircleAvatar(
                      backgroundColor: Color.fromARGB(0, 0, 0, 0),
                      maxRadius: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : (widget.discountStatus == DiscountStats.Valid
                      ? Icon(Icons.check)
                      : Icon(Icons.add)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: SimpleTooltip(
        hideOnTooltipTap: false,
        show: widget.simpleToolTipFlag,
        animationDuration: Duration(milliseconds: 460),
        tooltipDirection: TooltipDirection.up,
        maxHeight: 150,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
        ballonPadding: EdgeInsets.all(0),
        backgroundColor: IColors.whiteTransparent,
        borderColor: IColors.themeColor,
        tooltipTap: widget.onTooltipTap,
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: AutoText(
            widget.simpleToolTipString,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        child: TextField(
          controller: widget.textEditingController,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
              hintText: "کد تخفیف",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      new BorderSide(color: IColors.darkGrey, width: 1)),
              prefixIcon: disCountPrefixIcon()),
        ),
      ),
    );
  }
}
