import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/blocs/MedicalTestBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/utils/Device.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class MedicalTestPage extends StatefulWidget {
  final Function(String, dynamic) onPush;

  MedicalTestPage({Key key, @required this.onPush}) : super(key: key);

  @override
  _MedicalTestPageState createState() => _MedicalTestPageState();
}

class _MedicalTestPageState extends State<MedicalTestPage> {
  MedicalTestBloc _bloc = MedicalTestBloc();
  StreamController<Answer> answeringController = BehaviorSubject();
  HashMap<int, int> patientAnswers = HashMap();

  @override
  void initState() {
    answeringController.stream.listen((newAnswer) {
      patientAnswers[newAnswer.id] = newAnswer.score;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.add(GetTest(id: 3));
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocBuilder<MedicalTestBloc, MedicalTestState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is GetTestLoaded)
                  return _medicalTestWidget(state.result);
                else if (state is GetTestLoading)
                  return APICallLoading();
                else
                  return APICallError();
              }),
        ),
      ),
    );
  }

  _medicalTestWidget(MedicalTest test) =>
      BlocBuilder<EntityBloc, EntityState>(builder: (context, state) {
        if (state is EntityLoaded) {
          if (state.entity.mEntity != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
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
                  ],
                ),
                ALittleVerticalSpace(),
                state.entity.isDoctor ? _sendToPatientIcon() : SizedBox(),
                ALittleVerticalSpace(),
                QuestionList(test.questions, answeringController, context),
                MediumVerticalSpace(),
                state.entity.isDoctor
                    ? SizedBox()
                    : _showTestResultButtonWidget(test.questions.length),
                MediumVerticalSpace()
              ],
            );
          }
        }
        return APICallLoading();
      });

  Widget _sendToPatientIcon() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
        onTap: (){
          /// TODO mosio: it should open up a dialog to send this test to patient
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ActionButton(
            title: "ارسال برای" + "\n" + "بیمار",
            width: 100,
            height: 80,
            textColor: Colors.white,
            borderRadius: 10,
            color: IColors.themeColor,
          ),
        ),
      ),
      Padding(padding: const EdgeInsets.only(right: 20), child: SizedBox())
    ]);
  }

  _showTestResultButtonWidget(int questionsCount) => Center(
        child: ActionButton(
            width: MediaQuery.of(context).size.width * 0.5,
            title: "مشاهده پاسخ",
            color: IColors.themeColor,
            borderRadius: 15,
            callBack: () => showTestResult(questionsCount)),
      );

  void showTestResult(int questionsCount) {
    if (patientAnswers.values.length != questionsCount) {
      showOneButtonDialog(
          context, "لطفا به همه سوالات پاسخ دهید", "باشه", () {});
    } else {
      final score = calculateTestScore();
      if (score >= 0) {
        showOneButtonDialog(
            context,
            "ریسک آلزایمر بالا است ",
            "رزرو ویزیت",
            () => widget.onPush(
                NavigatorRoutes.doctorDialogue,
                BlocProvider.of<EntityBloc>(context)
                    .state
                    .entity
                    .partnerEntity));
      } else {
        showOneButtonDialog(context, "ریسک آلزایمر پایین است ", "متوجه شدم",
            () => Navigator.pop(context));
      }
    }
  }

  calculateTestScore() =>
      patientAnswers.values.reduce((sum, score) => sum + score);

  void dispose() {
    answeringController.close();
    super.dispose();
  }
}

class QuestionList extends StatelessWidget {
  final List<Question> questions;
  final BuildContext context;
  StreamController<Answer> answeringController = BehaviorSubject();

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
          QuestionAnswersWidget(question.answers, answeringController),
          MediumVerticalSpace(),
        ],
      );

  _questionLabelWidget(String label) => Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: Text(
            label,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
}

class QuestionAnswersWidget extends StatefulWidget {
  final List<Answer> answers;
  final StreamController<Answer> answeringController;

  QuestionAnswersWidget(this.answers, this.answeringController);

  @override
  _QuestionAnswersWidgetState createState() => _QuestionAnswersWidgetState();
}

class _QuestionAnswersWidgetState extends State<QuestionAnswersWidget> {
  int currentAnswer;

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for (var index = 0; index < widget.answers.length; index++)
            ActionButton(
                width: 100,
                title: widget.answers[index].text,
                color: getButtonColor(widget.answers[index].id),
                textColor: Colors.black,
                borderRadius: 15,
                fontSize: 17,
                boxShadowFlag: true,
                callBack: () => answerClicked(widget.answers[index]))
        ]);
  }

  answerClicked(Answer answer) {
    setState(() {
      currentAnswer = answer.id;
      widget.answeringController.add(answer);
    });
  }

  getButtonColor(int id) => currentAnswer == id ? IColors.blue : Colors.white;
}
