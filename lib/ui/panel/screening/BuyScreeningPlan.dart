import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
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

enum DiscountStats { Null, Loading, Valid, Invalid }

class _BuyScreeningPageState extends State<BuyScreeningPage> {
  TextEditingController _discountController = TextEditingController();
  DiscountStats discountStatus = DiscountStats.Null;
  double discountPercent;
  ScreeningBloc _screeningBloc;

  AlertDialog _loadingDialog = getLoadingDialog();
  BuildContext _loadingContext;

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

    _screeningBloc.buyStream.listen((event) {
      if (event.status == Status.LOADING) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              _loadingContext = context;
              return _loadingDialog;
            },
            barrierDismissible: false);
      } else if (event.status == Status.COMPLETED) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }
        BlocProvider.of<ScreeningBloc>(context).add(GetPatientScreening());
        Navigator.pop(context);
      } else if (event.status == Status.ERROR) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }

        /// TODO
      }
      setState(() {});
    });

    _screeningBloc.discountStream.listen((event) {
      if (event.status == Status.LOADING) {
        discountStatus = DiscountStats.Loading;
      } else if (event.status == Status.COMPLETED) {
        discountStatus = DiscountStats.Valid;
        discountPercent = event.data.percent;
      } else if (event.status == Status.ERROR) {
        toast(context, "کد تخفیف نامعتبر است");
        discountStatus = DiscountStats.Null;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
    Widget disCountPrefixIcon() {
      return GestureDetector(
        onTap: () {
          _screeningBloc.validateScreeningDiscount(_discountController.text);
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: discountStatus == DiscountStats.Null
                ? Icon(Icons.add)
                : (discountStatus == DiscountStats.Loading
                    ? CircleAvatar(
                        backgroundColor: Color.fromARGB(0, 0, 0, 0),
                        maxRadius: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : (discountStatus == DiscountStats.Valid
                        ? Icon(Icons.check)
                        : Icon(Icons.add)))),
      );
    }

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
            prefixIcon: disCountPrefixIcon()),
      ),
    );
  }

  Widget description(Screening screening) {
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
            Strings.neuronioClinicScreeningPlanDescription,
            style: TextStyle(fontSize: 13),
          ),
          for (String str in Strings.neuronioClinicScreeningSteps)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoText(
                str,
                style: TextStyle(fontSize: 13),
              ),
            )
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
        Column(
          children: [
            AutoText(replaceFarsiNumber(screening.price.toString()),
                style: TextStyle(
                    decoration: discountStatus == DiscountStats.Valid
                        ? TextDecoration.lineThrough
                        : null,
                    color: discountStatus == DiscountStats.Valid
                        ? null
                        : IColors.themeColor,
                    fontSize: 18,
                    fontWeight: discountStatus == DiscountStats.Valid
                        ? null
                        : FontWeight.w600)),
            discountStatus == DiscountStats.Valid
                ? AutoText(
                    replaceFarsiNumber((screening.price * (1 - discountPercent))
                        .toInt()
                        .toString()),
                    style: TextStyle(
                        color: IColors.themeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600))
                : SizedBox(),
          ],
        ),
        SizedBox(width: 5),
        AutoText("قیمت نهایی", style: TextStyle(fontSize: 16))
      ],
    );
  }

  Widget _mainWidget(Screening screening) {
    return SingleChildScrollView(
      child: Container(
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
                _screeningBloc.requestToBuyScreening(
                    screening.id,
                    discountStatus == DiscountStats.Valid
                        ? _discountController.text
                        : null);
              },
            ),
            ALittleVerticalSpace()
          ],
        ),
      ),
    );
  }
}
