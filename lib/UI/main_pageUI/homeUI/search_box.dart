import 'package:flutter/material.dart';
import '../../../constants/strings.dart';

class SearchBox extends StatelessWidget {
  double _getSearchBoxWidth(width) {
    return (width > 550 ? width * .6 : (width > 400 ? width * .5 : width * .4));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .85,
      padding: EdgeInsets.only(top: 5, bottom: 20, left: MediaQuery.of(context).size.width * .07, right: MediaQuery.of(context).size.width * .04),
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(80))),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
              ),
              child: SizedBox(
                  width: _getSearchBoxWidth(MediaQuery.of(context).size.width),
                  height: 60,
                  child: TextField(
                    controller: TextEditingController(),
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                        labelText:
                            Strings.searchBoxHint,
                        prefixIcon: Icon(
                          Icons.search,
                          size: 30,
                        ),
                        focusColor: Color.fromRGBO(254, 95, 85, 1),
                        fillColor: Color.fromRGBO(254, 95, 85, 1)),
                  )),
            ),
            Row(
              children: <Widget>[
                Text('تخصص',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                Container(
                  child: Icon(
                    Icons.filter_list,
                    size: 20,
                  ),
                  margin: EdgeInsets.only(left: 5),
                ),
              ],
            )
          ]),
//      ),child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          TextField(
//            textAlign: TextAlign.end,
//            textDirection: TextDirection.rtl,
//            decoration: InputDecoration(
//                hintText: Strings.searchBoxHint, icon: Icon(Icons.search)),
//          ),
//          Icon(Icons.filter_list)
//        ],
//      ),
    );
  }
}
