import 'dart:async';
import 'dart:collection';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/blocs/MedicalTestBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
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
    return SingleChildScrollView(
        child: BlocBuilder<MedicalTestBloc, MedicalTestState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is GetTestLoaded)
                return _medicalTestWidget(state.result);
              else if (state is GetTestLoading)
                return APICallLoading();
              else
                return APICallError();
            }));
  }

  _medicalTestWidget(MedicalTest test) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          DocUpHeader(title: test.name),
          ALittleVerticalSpace(),
          QuestionList(test.questions, answeringController),
          MediumVerticalSpace(),
          _showTestResultButtonWidget(test.questions.length),
          MediumVerticalSpace()
        ],
      );

  _showTestResultButtonWidget(int questionsCount) => Center(
        child: ActionButton(
            width: MediaQuery.of(context).size.width * 0.5,
            title: "ارسال نتایج",
            color: IColors.blue,
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
            () => widget.onPush(NavigatorRoutes.doctorDialogue,
                BlocProvider.of<EntityBloc>(context).state.entity.partnerEntity));
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
  StreamController<Answer> answeringController = BehaviorSubject();

  QuestionList(this.questions, this.answeringController);

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

  _questionLabelWidget(String label) => Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16.0),
        child: Text(label, textAlign: TextAlign.right),
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
