import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';
import 'package:Neuronio/repository/SearchRepository.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoCompleteTextField.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreeningDoctorSelectionPage extends StatefulWidget {
  final Function(String, UserEntity, int, VisitSource) onPush;
  final int screeningId;

  ScreeningDoctorSelectionPage({Key key, this.onPush, this.screeningId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreeningDoctorSelectionPageState();
  }
}

class ScreeningDoctorSelectionPageState
    extends State<ScreeningDoctorSelectionPage> {
  ScreeningBloc _screeningBloc = ScreeningBloc();
  TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// dirty code
  List<UserEntity> allFetchedDoctors = [];

  AlertDialog _loadingDialog = getLoadingDialog();
  BuildContext _loadingContext;

  ScreeningDoctorSelectionPageState();

  @override
  void initState() {
    _screeningBloc.doctorSelectionStream.listen((event) {
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
        showOneButtonDialog(context, "دکتر شما با موفقیت تعیین گردید.", "تایید",
            () async {
          EntityAndPanelUpdater.updateEntity();
          Navigator.pop(context);
          BlocProvider.of<ScreeningBloc>(context)
              .add(GetPatientScreening(withLoading: true));

          /// fetching doctor date and got push to doctor dialog for requesting for visit
          LoadingAlertDialog loadingAlertDialog = LoadingAlertDialog(context);
          loadingAlertDialog.showLoading();
          int doctorId = _findDoctorIdByNameFormFetchedDoctors();
          UserEntity doctor = await DoctorRepository().getDoctor(doctorId);
          loadingAlertDialog.disposeDialog();
          widget.onPush(NavigatorRoutes.doctorDialogue, doctor,
              widget.screeningId, VisitSource.SCREENING);
        });
      } else if (event.status == Status.ERROR) {
        if (_loadingContext != null) {
          Navigator.of(_loadingContext).pop();
        }
        showOneButtonDialog(
            context, InAppStrings.requestFailed, InAppStrings.okAction, () {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    try {
      _controller?.dispose();
    } catch (e) {}

    try {
      _screeningBloc.reNewStreams();
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
            InAppStrings.screeningDoctorSelection,
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
            items: allFetchedDoctors.map((e) => e.fullName).toList(),
            suggestionsCallback: (pattern) async {
              if (pattern == null || pattern.length <= 1) {
                return null;
              }
              SearchRepository searchRepository = SearchRepository();
              SearchResult searchResult =
                  await searchRepository.searchDoctor(pattern, null, null);
              allFetchedDoctors.addAll(searchResult.doctorResults);
              return searchResult.doctorResults.map((e) => e.fullName).toList();
            }),
      ),
    );
  }

  int _findDoctorIdByNameFormFetchedDoctors() {
    int doctorId;
    for (UserEntity doctor in allFetchedDoctors) {
      if (doctor.fullName == _controller.text) {
        doctorId = doctor.id;
      }
    }
    return doctorId;
  }

  Widget applyButton() {
    return ActionButton(
      title: "ویرایش",
      color: IColors.themeColor,
      height: 45,
      callBack: () async {
        if (_formKey.currentState.validate()) {
          int doctorId = _findDoctorIdByNameFormFetchedDoctors();
          _screeningBloc.requestToSetDoctorForScreeningPlan(
              widget.screeningId, doctorId);
        }
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
              topRight: NeuronioHeader(
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
