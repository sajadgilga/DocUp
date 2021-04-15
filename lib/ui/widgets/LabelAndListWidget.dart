import 'package:Neuronio/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ActionButton.dart';
import 'AutoText.dart';
import 'VerticalSpace.dart';

class LabelAndListWidget extends StatefulWidget {
  final String title;
  final List<String> items;
  final Set<int> selectedIndex;
  final Function(String, int) callback;
  final bool smallSize;
  final bool showTitle;

  LabelAndListWidget(
      {this.title,
      this.items,
      this.selectedIndex,
      this.callback,
      this.smallSize,
      this.showTitle = true});

  @override
  _LabelAndListWidgetState createState() => _LabelAndListWidgetState();
}

class _LabelAndListWidgetState extends State<LabelAndListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              !widget.showTitle ? Container() : _labelWidget(),
            ],
          ),
        ),
        ALittleVerticalSpace(),
        _listWidget()
      ],
    );
  }

  Widget _listWidget() => Container(
        height: 50,
        child: ListView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (var index = 0; index < widget.items.length; index++)
              Wrap(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                    child: ActionButton(
                      width: widget.smallSize != null && widget.smallSize
                          ? 120
                          : 160,
                      color: widget.selectedIndex != null &&
                              widget.selectedIndex.contains(index)
                          ? IColors.themeColor
                          : Colors.grey,
                      title: widget.items[index],
                      callBack: () => widget.callback(widget.title, index),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );

  Widget _labelWidget() => AutoText(
        widget.title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.right,
      );
}
