import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'MyPartnersResultList.dart';

class MyPartners extends StatelessWidget {
  final Function(String, UserEntity) onPush;

//  SearchBloc searchBloc = SearchBloc();

  MyPartners({@required this.onPush});

  void _initialSearch(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor)
      searchBloc.add(SearchPatient(
        text: "",
      ));
    else if (_state.entity.isPatient) if (_state.entity.mEntity != null) {
      searchBloc.add(SearchDoctor(
          isMyDoctors: true));
    } else {
      BlocProvider.of<EntityBloc>(context).add(EntityGet());
      searchBloc.add(ErrorEvent());
    }
  }

  @override
  void dispose() {}

  Widget _header(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(),
          child: AutoText(
            entity.isPatient ? "پزشکان من" : "بیماران من",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: Container(
              width: 25,
              child: Image.asset(
                Assets.panelMyDoctorIcon,
                width: 25,
                height: 25,
                color: IColors.themeColor,
              )),
        ),
      ],
    );
  }

  Widget _resultList() {
    return BlocBuilder <SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoaded) {
          return MyPartnersResultList(
            onPush: onPush,
            isDoctor: state.result.isDoctor,
            results: (state.result.isDoctor
                ? state.result.doctorResults
                : state.result.patientResults),
            isRequestsOnly: false,
          );
        } else if (state is SearchError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 30,
              ),
              APICallError(
                () {
                  _initialSearch(context);
                },
                tightenPage: true,
              ),
            ],
          );
        } else if (state is SearchLoading) {
          if (state.result == null)
            return Container(
              child: Waiting(),
            );
          else
            return MyPartnersResultList(
              onPush: onPush,
              isDoctor: state.result.isDoctor,
              results: (state.result.isDoctor
                  ? state.result.doctorResults
                  : state.result.patientResults),
              isRequestsOnly: false,
            );
        }
        return Container(
          child: Waiting(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialSearch(context);
//    _search(context);
//    _controller.addListener((){print(_controller.text); });
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          PageTopLeftIcon(
            topLeft: Icon(
              Icons.arrow_back,
              color: IColors.themeColor,
              size: 20,
            ),
            topLeftFlag: false,
            topRight: Padding(
              padding: EdgeInsets.only(right: 25),
              child: menuLabel("پنل کاربری"),
            ),
            topRightFlag: true,
            onTap: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 25, top: 20),
            child: _header(context),
          ),
          _resultList()
        ],
      ),
    );
  }
}
