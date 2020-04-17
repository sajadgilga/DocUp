
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:docup/utils/UiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AccountPage extends StatefulWidget {
  final ValueChanged<String> onPush;
  final ValueChanged<String> globalOnPush;

  AccountPage({Key key, @required this.onPush, this.globalOnPush}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntityBloc, EntityState>(
      builder: (context, state) {
        if (state is EntityLoaded) {
          if (state.entity.mEntity != null) {
            var user = state.entity.mEntity.user;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _docUpIcon(),
                Center(child: Text("پروفایل من", style: TextStyle(color: IColors.themeColor, fontSize: 30))),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("اطلاعات کاربری", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text("${user.firstName} ${user.lastName}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text("${replaceFarsiNumber(user.phoneNumber)}", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(width: 20),
                    Avatar(avatar:user.avatar),
                  ],
                ),
                Padding(
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
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("اعتبار من", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                ),
                Center(
                  child: Container(
                    width: 200,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,borderRadius: BorderRadius.all(Radius.circular(20)), color: IColors.darkBlue),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(" ۲۰,۰۰۰ ریال ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20), textDirection: TextDirection.rtl,),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ActionButton(
                    title: "افزایش اعتبار",
                    icon: Icon(Icons.add),
                    color: IColors.themeColor,
                    callBack: () => showNextVersionDialog(context),
                  ),
                )
              ],
            );
          }
        }
        return Container();
      },
    );
  }


  Widget _docUpIcon() {
    return Container(
      padding: EdgeInsets.only(top: 20, right: 20),
      child: SvgPicture.asset(
        'assets/DocUpHome.svg',
        width: 35,
        height: 35,
      ),
      alignment: Alignment.centerRight,
    );
  }


}
