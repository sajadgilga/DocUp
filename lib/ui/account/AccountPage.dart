import 'package:docup/blocs/CreditBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/utils/UiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  final ValueChanged<String> onPush;
  final ValueChanged<String> globalOnPush;

  AccountPage({Key key, @required this.onPush, this.globalOnPush})
      : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  CreditBloc _paymentBloc;

  AlertDialog _loadingDialog = getLoadingDialog();
  bool _loadingEnable;

  @override
  void initState() {
    _paymentBloc = BlocProvider.of<CreditBloc>(context);
    _paymentBloc.listen((event) {
      if (!(event is AddCreditLoaded)){
        showDialog(
            context: context,
            builder: (BuildContext context) => _loadingDialog);
        _loadingEnable = true;
      } else {
        if (_loadingEnable) {
          Navigator.of(context).pop();
          _loadingEnable = false;
        }
        _launchURL("https://pay.ir/pg/${event.result.token}");
      }
    });
    super.initState();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
        _addCreditWidget()
      ],
    ));
  }

  _userCreditWidget() => Center(
        child: Container(
          width: 200,
          height: 80,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: IColors.darkBlue),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              " ۲۰,۰۰۰ ریال ",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      );

  TextEditingController _amountTextController = TextEditingController();

  _addCreditWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.4,
            child: ActionButton(
                title: "افزایش اعتبار",
                icon: Icon(Icons.add),
                color: IColors.themeColor,
                callBack: () => _paymentBloc.add(AddCredit(
                    mobile: "09029191093",
                    amount: int.parse(_amountTextController.text)))),
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.5,
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
                  hintText: "مبلغ مورد نظر را وارد نمایید",
                  fillColor: Colors.white70),
            ),
          ),
        ],
      );

  _userCreditLabelWidget() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text("اعتبار من",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right),
      );

  _changePasswordWidget(BuildContext context) => Padding(
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
                  Avatar(avatar: user.avatar),
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
