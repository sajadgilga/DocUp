import 'dart:math';

import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectClinicWidget extends StatefulWidget {
  final TextEditingController _controller;

  SelectClinicWidget(this._controller);

  @override
  _SelectClinicWidgetState createState() => _SelectClinicWidgetState();
}

class _SelectClinicWidgetState extends State<SelectClinicWidget> {
  SearchBloc searchBloc = SearchBloc();

  void _initialSearch() {
    searchBloc.add(SearchClinic());
  }

  @override
  void initState() {
    _initialSearch();
    super.initState();
  }

  @override
  void dispose() {}

  Widget _clinicDropDown() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoaded) {
          return _dropDown(context, state.result.clinicResults);
        } else if (state is SearchError) {
          return APICallError(
            () {
              _initialSearch();
            },
            tightenPage: true,
          );
        } else if (state is SearchLoading) {
          if (state.result == null)
            return Container(
              child: Waiting(),
            );
          else
            return _dropDown(context, state.result.clinicResults);
        }
        return Container(
          child: Waiting(),
        );
      },
    );
  }

  Widget _dropDown(BuildContext context, List<ClinicEntity> clinics) {
    double maxX = MediaQuery.of(context).size.width;
    double xSize = min(350, maxX) * 0.7;
    clinics = (clinics ?? []) +
        <ClinicEntity>[ClinicEntity(id: -1, clinicName: "هیچکدام")];

    widget._controller.text =
        intPossible(widget._controller.text, defaultValues: clinics.first.id)
            .toString();
    return Container(
      width: xSize,
      child: DropdownButton(
        value: intPossible(widget._controller.text,
            defaultValues: clinics.first.id),
        onChanged: (newValue) {
          setState(() {
            widget._controller.text = newValue.toString();
          });
        },
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: IColors.darkGrey,
        ),
        selectedItemBuilder: (context) {
          return (clinics ?? []).map((clinic) {
            return DropdownMenuItem(
              value: clinic.id,
              child: Container(
                height: 35,
                alignment: Alignment.center,
                child: AutoText(
                  " " + clinic.clinicName + " ",
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            );
          }).toList();
        },
        items: (clinics ?? []).map((clinic) {
          return DropdownMenuItem(
            value: clinic.id,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
//                              width: xSize * (33 / 100),
                      height: 35,
                      alignment: Alignment.center,
                      child: AutoText(
                        " " + clinic.clinicName + " ",
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: xSize,
                      alignment: Alignment.center,
                      child: AutoText(
                        " " + (clinic.clinicAddress ?? "") + " ",
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        fontSize: 16,
                        maxLines: 3,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 0.5,
                  color: Colors.black,
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget descriptionMessage() {
    return AutoText(
      InAppStrings.patientClinicSuggestionMessage,
      textDirection: TextDirection.rtl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: searchBloc,
      child: Container(
        child: Column(
          children: <Widget>[
            descriptionMessage(),
            ALittleVerticalSpace(),
            _clinicDropDown()
          ],
        ),
      ),
    );
  }
}
