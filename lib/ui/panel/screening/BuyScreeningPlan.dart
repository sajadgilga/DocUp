import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyScreeningPage extends StatefulWidget {
  final Function(String, UserEntity) onPush;

  BuyScreeningPage({@required this.onPush});

  @override
  _BuyScreeningPageState createState() => _BuyScreeningPageState();
}

class _BuyScreeningPageState extends State<BuyScreeningPage> {
  TextEditingController _discountController = TextEditingController();
  ScreeningBloc _screeningBloc;

  void _initialApiCall() {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      if (_state.entity.isPatient) {
        /// TODO clinic id should be dynamic here, customer journey incomplete
        _screeningBloc.getClinicScreeningPlan(4);
      }
    });
  }

  @override
  void dispose() {
    _screeningBloc.reNewStreams();
    super.dispose();
  }

  @override
  void initState() {
    _screeningBloc = BlocProvider.of<ScreeningBloc>(context);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialApiCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("check mark");
    return StreamBuilder<Response<Screening>>(
        stream: _screeningBloc.apiStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return DocUpAPICallLoading2();
                break;
              case Status.COMPLETED:
                return _mainWidget(snapshot.data.data);
                break;
              case Status.ERROR:
                return APICallError(() {
                  _initialApiCall();
                });
                break;
              default:
                return APICallError(() {
                  _initialApiCall();
                });
            }
          }
          return Container();
        });
  }

  Widget discountWidget() {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        controller: _discountController,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "کد تخفیف",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: new BorderSide(color: IColors.darkGrey, width: 1)),
        ),
      ),
    );
  }

  Widget description(Screening screening) {
    /// TODO
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AutoText(
            "توضیحات",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          AutoText(
            "بسمنیبسیتبد تسیدبنت یسدنبت دسنتیبد نتسیبد نتسیدبنتسید نتبد سنتیبن یدبن تیسدنب ت ....",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget priceWidget(Screening screening) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AutoText("تومان", style: TextStyle(fontSize: 16)),
        SizedBox(width: 5),
        AutoText(replaceFarsiNumber(screening.price.toString()),
            style: TextStyle(
                color: IColors.themeColor,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        SizedBox(width: 5),
        AutoText("قیمت نهایی", style: TextStyle(fontSize: 16))
      ],
    );
  }

  Widget _mainWidget(Screening screening) {
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
            topRightFlag: true,
            onTap: () {},
          ),
          description(screening),
          ALittleVerticalSpace(),
          discountWidget(),
          ALittleVerticalSpace(),
          priceWidget(screening),
          ALittleVerticalSpace(),
          ActionButton(
            title: "خرید پلن سنجش",
            color: IColors.themeColor,
            callBack: () {
              toast(context,"در آینده آماده می شود.");
            },
          ),
        ],
      ),
    );
  }
}
