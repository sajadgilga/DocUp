import 'dart:async';

import 'package:Neuronio/blocs/CreditBloc.dart';
import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DiscountTextField.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/EntityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_links/uni_links.dart';

class ActivateScreeningPage extends StatefulWidget {
  final Function(String, UserEntity) onPush;

  ActivateScreeningPage({@required this.onPush});

  @override
  _ActivateScreeningPageState createState() => _ActivateScreeningPageState();
}

class _ActivateScreeningPageState extends State<ActivateScreeningPage> {
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

  // bool _tooltipToggle = true;

  void _initialApiCall() {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      if (_state.entity.isPatient) {
        /// TODO clinic id should be dynamic here, customer journey incomplete
        _screeningBloc.getClinicScreeningPlan(NeuronioClinic.ClinicId);
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

        showOneButtonDialog(context, "پلن شما با موفقیت فعال شد.", "تایید", () {
          EntityAndPanelUpdater.updateEntity();
          Navigator.pop(context);
          BlocProvider.of<ScreeningBloc>(context)
              .add(GetPatientScreening(withLoading: true));
        });
      } else if (event.status == Status.ERROR) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }

        /// REMOVED: CHANGING CUSTOMER JOURNEY
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
        } else {
          showOneButtonDialog(context, InAppStrings.requestFailed,
              InAppStrings.okAction, () {});
        }
      }
      setState(() {});
    });

    /// REMOVED: CHANGING CUSTOMER JOURNEY
    _screeningBloc.discountStream.listen((event) {
      FocusScope.of(context).unfocus();
      if (event.status == Status.LOADING) {
        discountStatus = DiscountStats.Loading;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              _loadingContext = context;
              return _loadingDialog;
            });
      } else if (event.status == Status.COMPLETED) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }
        discountStatus = DiscountStats.Valid;
        discountPercent = event.data.percent;
        showBuyPopup();
      } else if (event.status == Status.ERROR) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }
        toast(context, "کد تخفیف نامعتبر است");
        discountStatus = DiscountStats.Null;
      }
      setState(() {});
    });
  }

  void showBuyPopup() {
    showTwoButtonDialog(
        context,
        "قیمت نهایی برای شما" +
            " ${discountStatus == DiscountStats.Valid ? replaceFarsiNumber(priceWithCommaSeparator((screening.price * (1 - discountPercent)).toInt())) : replaceFarsiNumber(screening.price.toString())} " +
            "تومان" +
            " است." +
            "\n" +
            "آیا از خرید خود مطمین هستید؟",
        InAppStrings.okAction,
        InAppStrings.cancelAction, () {
      /// apply
      _screeningBloc.requestActivateScreening(
          screening.id,
          discountStatus == DiscountStats.Valid
              ? _discountController.text
              : null);
    }, () {
      /// reject
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

  Widget description(Screening screening) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AutoText(
            InAppStrings.neuronioClinicScreeningPlanDescription,
            style: TextStyle(fontSize: 13),
          ),
          for (String str in InAppStrings.neuronioClinicScreeningSteps)
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

  /// REMOVED: CHANGING CUSTOMER JOURNEY
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
                size: 25,
              ),
              onTap: () {
                Navigator.pop(context);
              },
              topRightFlag: true,
              topRight: NeuronioHeader(
                title: "بسته ارزیابی سلامت‌جو",
                docUpLogo: false,
              ),
              topLeftFlag: CrossPlatformDeviceDetection.isIOS,
            ),
            description(screening),
            ALittleVerticalSpace(
              height: 150,
            ),
            DiscountTextField(
              textEditingController: _discountController,
              simpleToolTipString: InAppStrings.guidToSiteForMothersDays,
              discountStatus: discountStatus,
              discountButtonFlag: false,
              onTooltipTap: () {
                launchURL(InAppStrings.appSiteLink);
              },
              onDiscountIconTap: () {
                // _screeningBloc
                //     .validateScreeningDiscount(_discountController.text);
              },
              simpleToolTipFlag: false,
            ),
            ALittleVerticalSpace(),
            priceWidget(screening),
            ALittleVerticalSpace(height: 35),
            ActionButton(
              title: "فعال‌سازی پلن سنجش",
              color: IColors.themeColor,
              callBack: () {
                if ([null, ""].contains(_discountController.text)) {
                  showBuyPopup();
                } else {
                  _screeningBloc
                      .validateScreeningDiscount(_discountController.text);
                }

                /// REMOVED TO THE CHANGE OF UX
                // _screeningBloc.requestActivateScreening(
                //     screening.id,
                //     discountStatus == DiscountStats.Valid
                //         ? _discountController.text
                //         : null);
              },
            ),
            ALittleVerticalSpace()
          ],
        ),
      ),
    );
  }

  /// REMOVED: CHANGING CUSTOMER JOURNEY
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
