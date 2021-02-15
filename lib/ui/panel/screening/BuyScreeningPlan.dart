import 'dart:async';

import 'package:Neuronio/blocs/CreditBloc.dart';
import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:uni_links/uni_links.dart';

class BuyScreeningPage extends StatefulWidget {
  final Function(String, UserEntity) onPush;

  BuyScreeningPage({@required this.onPush});

  @override
  _BuyScreeningPageState createState() => _BuyScreeningPageState();
}

enum DiscountStats { Null, Loading, Valid, Invalid }

class _BuyScreeningPageState extends State<BuyScreeningPage> {
  CreditBloc _creditBloc = CreditBloc();
  bool _isRequestForPay = false;

  TextEditingController _discountController = TextEditingController();
  DiscountStats discountStatus = DiscountStats.Null;
  double discountPercent = 0;
  ScreeningBloc _screeningBloc;

  AlertDialog _loadingDialog = getLoadingDialog();
  BuildContext _loadingContext;
  Screening screening;
  StreamSubscription _sub;
  bool _tooltipToggle = true;

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
    try {
      _screeningBloc.reNewStreams();
    } catch (e) {}
    try {
      _sub.cancel();
    } catch (e) {}
    super.dispose();
  }

  @override
  void initState() {
    _screeningBloc = BlocProvider.of<ScreeningBloc>(context);
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialApiCall();
    initUniLinks();
    super.initState();

    _creditBloc.listen((event) {
      if ((event is AddCreditLoading) && _isRequestForPay) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              _loadingContext = context;
              return _loadingDialog;
            });
      } else if (event is AddCreditLoaded) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }
        launchURL(event.result.paymentUrl);
      } else if (event is AddCreditError) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }
        showOneButtonDialog(
            context,
            "پرداخت با خطا مواجه شد، لطفا از طریق راه های ارتباطی با ما تماس برقرار کنید.",
            "تایید",
            () {});
      }
    });

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
        showOneButtonDialog(context, "پلن شما با موفقیا خریداری شد.", "تایید",
            () {
          EntityAndPanelUpdater.updateEntity();
          Navigator.pop(context);
          BlocProvider.of<ScreeningBloc>(context)
              .add(GetPatientScreening(withLoading: true));
        });
      } else if (event.status == Status.ERROR) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }
        if ((event.error as ApiException).getCode() == 624) {
          showOneButtonDialog(
              context,
              "اعتبار داخل آپ شما برای خرید کافی نیست.",
              "هدایت به درگاه پرداخت", () {
            var _entity = BlocProvider.of<EntityBloc>(context).state.entity;
            _isRequestForPay = true;
            _creditBloc.add(AddCredit(
                type: AddCreditType.BuyScreeningPlan.index,
                mobile: _entity.mEntity.user.phoneNumber,
                amount: discountStatus == DiscountStats.Valid
                    ? (screening.price * (1 - discountPercent)).toInt() * 10
                    : screening.price * 10,
                extraCallBackParams: {
                  "code": discountStatus == DiscountStats.Valid
                      ? _discountController.text
                      : null,
                  "screening_id": screening.id
                }));
          });
        }
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
                screening = snapshot.data.data;
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
      child: SimpleTooltip(
        hideOnTooltipTap: false,
        show: true,
        animationDuration: Duration(milliseconds: 460),
        tooltipDirection: TooltipDirection.up,
        maxHeight: 150,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
        ballonPadding: EdgeInsets.all(0),
        backgroundColor: IColors.whiteTransparent,
        borderColor: IColors.themeColor,
        tooltipTap: () {
          launchURL(Strings.appSiteLink);
        },
        content: Stack(
          alignment: Alignment.topRight,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AutoText(
                Strings.guidToSiteForMothersDays,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
        child: TextField(
          controller: _discountController,
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
            AutoText(
                replaceFarsiNumber(priceWithCommaSeparator(screening.price)),
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
                    replaceFarsiNumber(priceWithCommaSeparator(
                        (screening.price * (1 - discountPercent)).toInt())),
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
            ALittleVerticalSpace(
              height: 150,
            ),
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

  Future<Null> initUniLinks() async {
    if (CrossPlatformDeviceDetection.isAndroid ||
        CrossPlatformDeviceDetection.isIOS) {
      try {
        /// profile page uni link will do the rest
        _sub = getUriLinksStream().listen((Uri link) {
          final query = link.queryParameters;
          if (query["success"] == "false") {
          } else {
            BlocProvider.of<ScreeningBloc>(context)
                .add(GetPatientScreening(withLoading: true));
            Navigator.pop(context);
          }
        }, onError: (err) {
          print("link error $err");
        });
      } on PlatformException {
        print("link error");
      }
    }
  }
}
