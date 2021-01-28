import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/panel/PanelAlert.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreeningPage extends StatefulWidget {
  final Function(String, UserEntity) onPush;

  ScreeningPage({@required this.onPush});

  @override
  _ScreeningPageState createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {

  void _initialApiCall() {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      if (_state.entity.isPatient) {
        /// TODO clinic id should be dynamic here, customer journey incomplete
        BlocProvider.of<ScreeningBloc>(context).add(GetPatientScreening());
      }
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialApiCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreeningBloc, ScreeningState>(
        builder: (context, state) {
          /// TODO
      if (state is ScreeningLoaded || true) {
        return Stack(
          children: [
            _mainWidget(),
            buyScreeningPanelAlert()
          ],
        );
      } else if (state is ScreeningLoading) {
        return DocUpAPICallLoading2();
      } else {
        return APICallError(() {
          _initialApiCall();
        });
      }
    });
  }

  Widget buyScreeningPanelAlert() {
    return PanelAlert(
      callback: () {
        widget.onPush(NavigatorRoutes.buyScreening,null);
      },
      label: "شما پلن ندارید و باید و ... خرید پلن غربالگری و توضیحات ان ...",
      buttonLabel: "توضیحات بیشتر درباره سنجش",
    );
  }

  Widget _header(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(),
          child: AutoText(
            "پزشک من",
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

  Widget _mainWidget() {
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
        ],
      ),
    );
  }
}
