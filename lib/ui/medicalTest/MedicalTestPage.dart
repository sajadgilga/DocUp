import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/SingleMedicalTestBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/MedicalTestRepository.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/SnackBar.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class MedicalTestPage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final MedicalTestPageData medicalTestPageInitData;

  MedicalTestPage(
      {Key key, @required this.onPush, @required this.medicalTestPageInitData})
      : super(key: key);

  @override
  _MedicalTestPageState createState() => _MedicalTestPageState();
}

class _MedicalTestPageState extends State<MedicalTestPage> {
  SingleMedicalTestBloc _bloc = SingleMedicalTestBloc();
  StreamController<QuestionAnswerPair> answeringController = BehaviorSubject();
  Map<int, Answer> patientAnswers = HashMap();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool firstInitialized = false;

  @override
  void initState() {
    answeringController.stream.listen((questionAnswerPair) {
      patientAnswers[questionAnswerPair.question.id] =
          questionAnswerPair.answer;
    });
    _initialApiCall();
    super.initState();
  }

  void _initialApiCall() {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    try {
      if (_state.entity.isDoctor) {
        if (widget.medicalTestPageInitData.patientEntity == null) {
          _bloc.add(
              GetTest(id: widget.medicalTestPageInitData.medicalTestItem.id));
        } else {
          _bloc.add(GetPatientTestAndResponse(
              testId: widget.medicalTestPageInitData.medicalTestItem.id,
              patientId: widget.medicalTestPageInitData.patientEntity.id));
        }
      } else {
        _bloc.add(GetPatientTestAndResponse(
            testId: widget.medicalTestPageInitData.medicalTestItem.id,
            patientId: _state.entity.mEntity.id));
      }
      this.firstInitialized = true;
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          /// to check that mEntity is Loaded Successfully
          child: firstInitialized
              ? _widget()
              : BlocBuilder<EntityBloc, EntityState>(
                  builder: (context, state) {
                    if (state is EntityLoaded) {
                      if (!firstInitialized) {
                        _initialApiCall();
                      }
                      return _widget();
                    } else if (state is EntityError) {
                      return APICallError(() {
                        BlocProvider.of<EntityBloc>(context).add(EntityGet());
                      });
                    } else {
                      return DocUpAPICallLoading2();
                    }
                  },
                ),
        ),
      ),
    );
  }

  _widget() {
    return BlocBuilder<SingleMedicalTestBloc, MedicalTestState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is GetTestLoaded)
            return _medicalTestWidget(state.result);
          else if (state is GetTestLoading)
            return DocUpAPICallLoading2();
          else
            return APICallError(
              () {
                _initialApiCall();
              },
            );
        });
  }

  _medicalTestWidget(MedicalTest test) {
    patientAnswers = test.oldAnswers;
    return BlocBuilder<EntityBloc, EntityState>(builder: (context, state) {
      if (state is EntityLoaded) {
        if (state.entity.mEntity != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ALittleVerticalSpace(),
              Stack(
                alignment: Alignment.center,
                children: [
                  PageTopLeftIcon(
                    topLeft: Icon(
                      Icons.arrow_back,
                      color: IColors.themeColor,
                      size: 20,
                    ),
                    onTap: () {
                      /// TODO
                      widget.onPush(NavigatorRoutes.root, null);
                    },
                    topRightFlag: false,
                    topLeftFlag: Platform.isIOS,
                  ),
                  DocUpHeader(
                    title: widget.medicalTestPageInitData.medicalTestItem.name,
                    docUpLogo: false,
                    color: IColors.black,
                  ),
                ],
              ),
              ALittleVerticalSpace(),
              state.entity.isDoctor
                  ? _sendToPatientSection(state.entity.mEntity, test)
                  : SizedBox(),
              ALittleVerticalSpace(),
              QuestionList(test.questions, answeringController, context),
              ALittleVerticalSpace(
                height: 30,
              ),
              state.entity.isDoctor ||
                      !widget.medicalTestPageInitData.editableFlag
                  ? SizedBox()
                  : _patientTestResultButton(test, state.entity.mEntity),
              MediumVerticalSpace()
            ],
          );
        }
      }
      return DocUpAPICallLoading2();
    });
  }

  Widget _sendToPatientSection(DoctorEntity doctorEntity, MedicalTest test) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
        onTap: () {
          SendToPatientDialog dialog =
              SendToPatientDialog(context, doctorEntity, test, _scaffoldKey);
          dialog.showTestSendDialog();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ActionButton(
            title: "ارسال برای" + "\n" + "بیمار",
            width: 110,
            height: 80,
            textColor: Colors.white,
            borderRadius: 10,
            color: IColors.themeColor,
          ),
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(right: 20),
          child: widget.medicalTestPageInitData.patientEntity == null
              ? SizedBox()
              : _userInfoWidget(widget.medicalTestPageInitData.patientEntity))
    ]);
  }

  _userInfoWidget(PatientEntity entity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AutoText(
              "${entity.user.firstName == null ? "" : entity.user.firstName} ${entity.user.lastName == null ? "" : entity.user.lastName}",
              fontSize: 16,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PolygonAvatar(
            imageSize: 70,
            user: entity.user,
          ),
        ),
      ],
    );
  }

  _patientTestResultButton(MedicalTest test, UserEntity userEntity) => Center(
        child: ActionButton(
            width: MediaQuery.of(context).size.width * 0.6,
            title: "مشاهده و ثبت پاسخ",
            color: IColors.themeColor,
            borderRadius: 15,
            fontSize: 16,
            callBack: () {
              showTestResultAndUploadResponse(test, userEntity);
            }),
      );

  void showTestResultAndUploadResponse(
      MedicalTest test, UserEntity userEntity) {
    if (patientAnswers.values.length != test.questions.length) {
      showOneButtonDialog(
          context, "لطفا به همه سوالات پاسخ دهید", "باشه", () {});
    } else {
      final score = calculateTestScore();
      // if (score >= 0) {
      //   showOneButtonDialog(
      //       context,
      //       "ریسک آلزایمر بالا است ",
      //       "رزرو ویزیت",
      //       () => widget.onPush(
      //           NavigatorRoutes.doctorDialogue,
      //           BlocProvider.of<EntityBloc>(context)
      //               .state
      //               .entity
      //               .partnerEntity));
      // } else {
      //   showOneButtonDialog(context, "ریسک آلزایمر پایین است ", "متوجه شدم",
      //       () => Navigator.pop(context));
      // }
      if (userEntity is PatientEntity) {
        MedicalTestResponse response = MedicalTestResponse(
            userEntity.id, test.id, this.patientAnswers,
            panelId: widget.medicalTestPageInitData.panelId);
        MedicalTestRepository medicalTestRepository = MedicalTestRepository();
        medicalTestRepository
            .addPatientResponse(response)
            .then((medicalTestResponseEntity) {
          if (medicalTestResponseEntity.success) {
            showOneButtonDialog(context, medicalTestResponseEntity.msg, "باشه",
                () {
              Navigator.pop(context);
              if (widget.medicalTestPageInitData.panelId != null) {
                try {
                  widget.medicalTestPageInitData.onDone();
                } catch (e) {}
              }
            });
          } else {
            showSnackBar(_scaffoldKey, medicalTestResponseEntity.msg);
          }
        });
      }
    }
  }

  calculateTestScore() {
    int res = 0;

    patientAnswers.values.forEach((element) {
      res += element.score;
    });
    return res;
  }

  void dispose() {
    try {
      answeringController.close();
    } catch (e) {}
    super.dispose();
  }
}

class QuestionList extends StatelessWidget {
  final List<Question> questions;
  final BuildContext context;
  StreamController<QuestionAnswerPair> answeringController = BehaviorSubject();

  QuestionList(this.questions, this.answeringController, this.context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var index = 0; index < questions.length; index++)
          _questionWidget(questions[index])
      ],
    );
  }

  _questionWidget(Question question) => Column(
        children: <Widget>[
          _questionLabelWidget(question.label),
          ALittleVerticalSpace(),
          QuestionAnswersWidget(question, answeringController),
          MediumVerticalSpace(),
        ],
      );

  _questionLabelWidget(String label) => Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: AutoText(
            label,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
}

class QuestionAnswersWidget extends StatefulWidget {
  final Question question;
  final StreamController<QuestionAnswerPair> answeringController;

  QuestionAnswersWidget(this.question, this.answeringController);

  @override
  _QuestionAnswersWidgetState createState() => _QuestionAnswersWidgetState();
}

class _QuestionAnswersWidgetState extends State<QuestionAnswersWidget> {
  int currentAnswer;

  @override
  void initState() {
    for (int i = 0; i < widget.question.answers.length; i++) {
      Answer element = widget.question.answers[i];
      if (element.selected != null && element.selected) {
        currentAnswer = element.id;
        break;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for (var index = 0; index < widget.question.answers.length; index++)
            ActionButton(
                width: 90,
                height: 40,
                title: widget.question.answers[index].text,
                color: getButtonColor(widget.question.answers[index].id),
                textColor: Colors.black,
                borderRadius: 10,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                boxShadowFlag: true,
                callBack: () {
                  var state = BlocProvider.of<EntityBloc>(context).state;
                  if (state.entity.isPatient) {
                    answerClicked(widget.question.answers[index]);
                  }
                })
        ]);
  }

  answerClicked(Answer answer) {
    setState(() {
      currentAnswer = answer.id;
      widget.answeringController
          .add(QuestionAnswerPair(widget.question, answer));
    });
  }

  getButtonColor(int id) =>
      currentAnswer == id ? IColors.themeColor : Colors.white;
}

class SendToPatientDialog {
  DoctorEntity doctorEntity;
  BuildContext dialogContext;
  BuildContext context;
  StateSetter alertStateSetter;
  UserEntity selectedPatient;
  MedicalTest medicalTest;
  GlobalKey<ScaffoldState> _scaffoldKey;

  int actionButtonStatus = 0;

  ///0 for done,1 for loading, 2 for error

  SendToPatientDialog(
      this.context, this.doctorEntity, this.medicalTest, this._scaffoldKey) {}

  void showTestSendDialog() {
    StreamSubscription streamSubscription;
    SingleMedicalTestBloc medicalTestBloc = SingleMedicalTestBloc();
    streamSubscription = medicalTestBloc.apiStream.listen((event) {
      handleResponse(event);
    });
    SearchBloc _searchBloc = SearchBloc();
    _initialSearch(_searchBloc, context);
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter dialogStateSetter) {
              alertStateSetter = dialogStateSetter;
              dialogContext = context;
              return Container(
                constraints: BoxConstraints.tightFor(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints.tightFor(
                            width: MediaQuery.of(context).size.width * 0.8),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            ALittleVerticalSpace(),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoText(
                                  "ارسال برای",
                                  color: IColors.darkGrey,
                                  fontSize: 15,
                                ),
                              ],
                            ),
                            ALittleVerticalSpace(
                              height: 20,
                            ),
                            menuLabel(
                              "مطب مجازی",
                            ),
                            ALittleVerticalSpace(
                              height: 20,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AutoText(
                                  "بیماران در حال درمان",
                                  color: IColors.themeColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Image.asset(
                                  Assets.panelMyDoctorIcon,
                                  color: IColors.themeColor,
                                  width: 20,
                                  height: 20,
                                )
                              ],
                            ),
                            ALittleVerticalSpace(
                              height: 30,
                            ),
                            BlocProvider.value(
                              value: _searchBloc,
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  {
                                    if (state is SearchLoaded) {
                                      List<Widget> list = [];
                                      state.result.patient_results
                                          .forEach((element) {
                                        list.add(getPatientItem(element));
                                      });
                                      return Container(
                                        height: list.length * 45.0,
                                        child: ListView(
                                          children: list,
                                        ),
                                      );
                                    }
                                    if (state is SearchError)
                                      return Container(
                                        child: AutoText('error!'),
                                      );
                                    if (state is SearchLoading) {
                                      if (state.result == null)
                                        return Container(
                                          child: Waiting(),
                                        );
                                      else {
                                        List<Widget> list = [];
                                        state.result.patient_results
                                            .forEach((element) {
                                          list.add(getPatientItem(element));
                                        });
                                        return Container(
                                          height: list.length * 45.0,
                                          child: ListView(
                                            children: list,
                                          ),
                                        );
                                      }
                                    }
                                    return Waiting();
                                  }
                                },
                              ),
                            ),
                            ALittleVerticalSpace(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ActionButton(
                                  title: "ارسال",
                                  color: IColors.themeColor,
                                  loading: actionButtonStatus == 1,
                                  callBack: () {
                                    if (selectedPatient == null) {
                                      showSnackBar(_scaffoldKey,
                                          "یکی از بیماران را انتخاب کنید.");
                                    } else
                                      medicalTestBloc.addTestToPatient(
                                          medicalTest.id, selectedPatient.id);
                                  },
                                  borderRadius: 10,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }).then((value) {
      streamSubscription.cancel();
    });
  }

  void _initialSearch(SearchBloc searchBloc, context) {
    searchBloc.add(SearchPatient(
      text: "",
    ));
  }

  Widget getPatientItem(UserEntity userEntity) {
    bool selected = false;
    if (this.selectedPatient != null &&
        this.selectedPatient.id == userEntity.id) {
      selected = true;
    }
    return GestureDetector(
      onTap: () {
        alertStateSetter(() {
          selectedPatient = userEntity;
        });
      },
      child: Container(
        height: 45,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: selected ? IColors.themeColor : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                children: [
                  AutoText(
                    userEntity.fullName,
                    color: selected ? Colors.white : IColors.darkGrey,
                    fontSize: 12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.circle,
                    color: selected ? Colors.white : IColors.darkGrey,
                    size: 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleResponse(response) {
    try {
      switch (response.status) {
        case Status.LOADING:
          alertStateSetter(() {
            actionButtonStatus = 1;
          });
          break;
        case Status.ERROR:
          alertStateSetter(() {
            actionButtonStatus = 2;
          });
          Future.delayed(Duration(seconds: 2), () {
            alertStateSetter(() {
              actionButtonStatus = 0;
            });
          });
          break;
        case Status.COMPLETED:
          alertStateSetter(() {
            actionButtonStatus = 0;
          });
          Navigator.maybePop(dialogContext);
          showSnackBar(_scaffoldKey, "تست با موفقیت برای بیمار ارسال شد",
              context: context);
          break;
        default:
          break;
      }
    } catch (e) {}
  }

  void fetchPatients() {}

  void sendTestToPatient(dataBloc) {}
}
