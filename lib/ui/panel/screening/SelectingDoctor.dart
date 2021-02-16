import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/repository/SearchRepository.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoCompleteTextField.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:flutter/material.dart';

class ScreeningDoctorSelectionPage extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  final int screeningId;

  ScreeningDoctorSelectionPage({Key key, this.onPush, this.screeningId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScreeningDoctorSelectionPageState(onPush: onPush);
  }
}

class ScreeningDoctorSelectionPageState
    extends State<ScreeningDoctorSelectionPage> {
  final Function(String, UserEntity) onPush;
  TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ScreeningDoctorSelectionPageState({@required this.onPush});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    try {
      _controller?.dispose();
    } catch (e) {}
    super.dispose();
  }

  Widget description() {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ALittleVerticalSpace(),
          AutoText(
            Strings.screeningDoctorSelection,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget doctorSelectionAutoComplete() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: AutoCompleteTextField(
            controller: _controller,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: new BorderSide(color: IColors.darkGrey, width: 1)),
            hintText: "نام دکتر را وارد کنید",
            forced: false,
            notFoundError: "دکتری با این نام وجود ندارد.",
            suggestionsCallback: (pattern) async {
              if (pattern == null || pattern.length <= 1) {
                return null;
              }
              SearchRepository searchRepository = SearchRepository();
              SearchResult searchResult =
                  await searchRepository.searchDoctor(pattern, null, null);
              return searchResult.doctorResults.map((e) => e.fullName).toList();
            }),
      ),
    );
  }

  Widget applyButton() {
    return ActionButton(
      title: "ویرایش",
      color: IColors.themeColor,
      height: 45,
      callBack: () {
        if (_formKey.currentState.validate()) {}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Form(
        key: _formKey,
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
              topRight: DocUpHeader(
                title: "ویزیت با پزشک",
                docUpLogo: false,
              ),
              topLeftFlag: CrossPlatformDeviceDetection.isIOS,
            ),
            description(),
            ALittleVerticalSpace(
              height: 100,
            ),
            doctorSelectionAutoComplete(),
            ALittleVerticalSpace(
              height: 30,
            ),
            applyButton()
          ],
        ),
      ),
    );
  }
}
