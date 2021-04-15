import 'package:Neuronio/blocs/ICATestBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ICATestScoring extends StatefulWidget {
  final int screeningStepId;
  final UserEntity partner;

  ICATestScoring({this.partner, this.screeningStepId});

  @override
  _ICATestScoringState createState() => _ICATestScoringState();
}

class _ICATestScoringState extends State<ICATestScoring> {
  TextEditingController _icaScoreController = TextEditingController();
  TextEditingController _accuracyController = TextEditingController();
  TextEditingController _continuousAccuracyController = TextEditingController();
  TextEditingController _speedController = TextEditingController();
  TextEditingController _continuousSpeedController = TextEditingController();
  TextEditingController _attentionController = TextEditingController();
  bool initialDataLoaded = false;
  ICATestBloc _icaTestBloc = ICATestBloc();

  AlertDialog _loadingDialog = getLoadingDialog();
  BuildContext _loadingContext;

  final _formKey = GlobalKey<FormState>();

  void _initialApiCall() {
    _icaTestBloc
        .add(GetScreeningICATestScore(screeningStepId: widget.screeningStepId));
  }

  @override
  void initState() {
    _initialApiCall();

    /// initializing text fields if needed
    _icaTestBloc.updateScoreStream.listen((response) {
      switch (response.status) {
        case Status.LOADING:
          showDialog(
              context: context,
              builder: (BuildContext context) {
                _loadingContext = context;
                return _loadingDialog;
              });
          break;
        case Status.ERROR:
          if (_loadingContext != null) {
            Navigator.of(_loadingContext).pop();
          }
          showOneButtonDialog(
              context, "عملیات با خطا مواجه شد.", InAppStrings.okAction, () {});
          break;
        case Status.COMPLETED:
          if (_loadingContext != null) {
            Navigator.of(_loadingContext).pop();
          }
          showOneButtonDialog(
              context, "عملیات با موفقیت انجام شد.", InAppStrings.okAction, () {
            Navigator.pop(context);
          });
          break;
        default:
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ICATestBloc, ICAScoresState>(
        bloc: _icaTestBloc,
        builder: (context, state) {
          if (state is ICATestScoreLoaded || state.result != null) {
            return _mainWidget(state.result);
          } else if (state is IcaTestScoreLoading) {
            return DocUpAPICallLoading2();
          } else {
            return APICallError(() {
              _initialApiCall();
            });
          }
        });
  }

  Widget _mainWidget(ICATestScores icaTestScore) {
    if (!initialDataLoaded) {
      initialDataLoaded = true;
      _icaScoreController.text = icaTestScore.icaIndex?.toString() ?? "";
      _accuracyController.text = icaTestScore.accuracy?.toString() ?? "";
      _continuousAccuracyController.text =
          icaTestScore.accuracyMaintenance?.toString() ?? "";
      _speedController.text = icaTestScore.speed?.toString() ?? "";
      _continuousSpeedController.text =
          icaTestScore.speedMaintenance?.toString() ?? "";
      _attentionController.text = icaTestScore.attention?.toString() ?? "";
    }

    return SingleChildScrollView(
      child: Container(
        child: Form(
          key: _formKey,
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
                  child: menuLabel("نمره دهی تست ICA", fontSize: 20),
                ),
                topRightFlag: true,
                onTap: () {},
              ),
              _scoreTextFormFieldItem(_icaScoreController, "امتیاز ICA"),
              _scoreTextFormFieldItem(_accuracyController, "دقت"),
              _scoreTextFormFieldItem(
                  _continuousAccuracyController, "تداوم دقت"),
              _scoreTextFormFieldItem(_speedController, "سرعت"),
              _scoreTextFormFieldItem(_continuousSpeedController, "تداوم سرعت"),
              _scoreTextFormFieldItem(_attentionController, "میزان توجه"),
              ALittleVerticalSpace(),
              _submitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return ActionButton(
      title: InAppStrings.okAction,
      color: IColors.themeColor,
      callBack: () {
        if (_formKey.currentState.validate())
          _icaTestBloc.updateIcaTestScores(
              ICATestScores(
                  icaIndex: intPossible(_icaScoreController.text),
                  accuracy: intPossible(_accuracyController.text),
                  attention: intPossible(_attentionController.text),
                  accuracyMaintenance:
                      intPossible(_continuousAccuracyController.text),
                  speedMaintenance:
                      intPossible(_continuousSpeedController.text),
                  speed: intPossible(_speedController.text)),
              widget.screeningStepId);
      },
    );
  }

  Widget _scoreTextFormFieldItem(
      TextEditingController controller, String lable) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: 50,
          child: TextFormField(
            controller: controller,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: false),
            maxLines: 1,
            style: TextStyle(fontSize: 16),
            validator: (value) {
              int score = intPossible(value, defaultValues: null);
              if (score != null && (score > 100 || score < 0)) {
                return "نمره خارج از بازه صفر تا صد است.";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: lable,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      new BorderSide(color: IColors.darkGrey, width: 1)),
            ),
          ),
        ),
      ),
    );
  }
}
