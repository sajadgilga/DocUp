import 'package:docup/blocs/CreditBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  final ValueChanged<String> onPush;
  final Function(String, UserEntity) globalOnPush;
  final String defaultCreditForCharge;

  AccountPage(
      {Key key,
      @required this.onPush,
      this.globalOnPush,
      this.defaultCreditForCharge})
      : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  CreditBloc _creditBloc = CreditBloc();

  AlertDialog _loadingDialog = getLoadingDialog();
  bool _loadingEnable;
  bool _isRequestForPay = false;
  BuildContext loadingContext;

  @override
  void initState() {
    _loadingEnable = false;
    _creditBloc.listen((event) {
      if (!(event is AddCreditLoaded) && _isRequestForPay) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              loadingContext = context;
              return _loadingDialog;
            });
        _loadingEnable = true;
      } else {
        if (_loadingEnable) {
          Navigator.of(loadingContext).pop();
          _loadingEnable = false;
          launchURL("https://pay.ir/pg/${event.result.token}");
        }
      }
    });
    _amountTextController.text = widget.defaultCreditForCharge;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        _docUpIcon(),
        _headerWidget(),
        SizedBox(height: 10),
        _userInfoLabelWidget(),
        _userInfoWidget(),
        _changePasswordWidget(context),
        _userCreditLabelWidget(),
        _userCreditWidget(),
        SizedBox(height: 20),
        _addCreditWidget(),
        SizedBox(height: 10),
        _supportWidget()
      ],
    ));
  }

  _supportWidget() => GestureDetector(
        onTap: () => launch("tel://09335705997"),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                      fontFamily: 'iransans',
                      color: Colors.black87,
                      fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            "لطفا انتقادات و پیشنهادات خود را با شماره تماس ۰۹۳۳۵۷۰۵۹۹۷ در واتس اپ یا تلگرام با تیم"),
                    TextSpan(
                        text: " داکآپ ",
                        style: TextStyle(
                            color: IColors.themeColor,
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: "در میان بگذارید ")
                  ]),
            )),
      );

  _userCreditWidget() => BlocBuilder<EntityBloc, EntityState>(
  builder: (context, state) {
      return Center(
        child: Container(
          width: 200,
          height: 64,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: IColors.darkBlue),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              " ${state is EntityLoaded && state.entity != null && state.entity.mEntity != null ? replaceFarsiNumber(state.entity.mEntity.user.credit) : "0"} ریال ",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      );
    });

  TextEditingController _amountTextController = TextEditingController();

  _addCreditWidget() {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    return Visibility(
      visible: entity.isPatient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.4,
            child: ActionButton(
                title: "افزایش اعتبار",
                icon: Icon(Icons.add),
                color: IColors.themeColor,
                callBack: () {
                  if (_amountTextController.text.isEmpty) {
                    toast(context, "لطفا مبلغ را وارد کنید");
                  } else {
                    _isRequestForPay = true;
                    _creditBloc.add(AddCredit(
                        mobile: entity.mEntity.user.phoneNumber,
                        amount: int.parse(_amountTextController.text)));
                  }
                }),
          ),
          Row(
            children: <Widget>[
              Text("ریال", style: TextStyle(fontSize: 18)),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  controller: _amountTextController,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(20.0),
                        ),
                      ),
                      filled: true,
                      hintStyle:
                          new TextStyle(color: Colors.grey[800], fontSize: 12),
                      hintText: "مبلغ را وارد نمایید",
                      fillColor: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _userCreditLabelWidget() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text("اعتبار من",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right),
      );

  _changePasswordWidget(BuildContext context) => Visibility(
        visible: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: <Widget>[
              ActionButton(
                color: Colors.grey,
                title: "تغییر رمز عبور",
                callBack: () => showNextVersionDialog(context),
              ),
            ],
          ),
        ),
      );

  _userInfoWidget() => BlocBuilder<EntityBloc, EntityState>(
        builder: (context, state) {
          if (state is EntityLoaded) {
            if (state.entity.mEntity != null) {
              var user = state.entity.mEntity.user;
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                          "${user.firstName == null ? "" : user.firstName} ${user.lastName == null ? "" : user.lastName}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("${replaceFarsiNumber(user.phoneNumber)}",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(width: 20),
                  Avatar(user: user),
                ],
              );
            } else
              return Container();
          } else
            return Container();
        },
      );

  _userInfoLabelWidget() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text("اطلاعات کاربری",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right),
      );

  _headerWidget() => Center(
      child: Text("پروفایل من",
          style: TextStyle(color: IColors.themeColor, fontSize: 30)));

  _docUpIcon() => Container(
        padding: EdgeInsets.only(top: 20, right: 20),
        child: SvgPicture.asset(
          'assets/docUpHomePatient.svg',
          width: 35,
          height: 35,
        ),
        alignment: Alignment.centerRight,
      );
}
