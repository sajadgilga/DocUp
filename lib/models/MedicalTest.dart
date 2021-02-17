import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/utils/Utils.dart';

class QuestionAnswerPair {
  final Question question;
  final QuestionAnswer answer;

  QuestionAnswerPair(this.question, this.answer);
}

class MedicalTestResponse {
  final int patientId;
  final int cognitiveTestId;
  final Map<int, QuestionAnswer> answers;

  /// panel
  final int panelTestId;
  final int panelId;

  /// screening
  final int screeningId;

  MedicalTestResponse(this.patientId, this.cognitiveTestId, this.answers,
      {this.panelId, this.panelTestId, this.screeningId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['patient_id'] = patientId;
    data['cognitive_test_id'] = cognitiveTestId;
    if (panelTestId != null) data['panel_test_id'] = panelTestId;
    if (screeningId != null) data['screening_step_id'] = screeningId;

    List<Map<String, dynamic>> res = [];
    List<int> questionIds = answers.keys.toList();
    questionIds.sort();
    for (int i = 0; i < questionIds.length; i++) {
      QuestionAnswer ans = answers[questionIds[i]];
      if (ans.type == QuestionType.MultipleChoice) {
        res.add({'question_id': questionIds[i], 'answer_id': ans.answer.id});
      } else if (ans.type == QuestionType.Descriptive) {
        res.add({'question_id': questionIds[i], 'desc': ans.text});
      }
    }
    data['questions'] = res;
    return data;
  }
}

enum MedicalPageDataType { Usual, Panel, Screening }

class MedicalTestPageData {
  final MedicalPageDataType type;
  final MedicalTestItem medicalTestItem;
  final PatientEntity patientEntity;
  final bool editableFlag;
  final bool sendableFlag;
  final Function onDone;

  /// panel
  final int panelId;

  /// screening
  final int screeningId;

  MedicalTestPageData(this.type,
      {this.medicalTestItem,
      this.patientEntity,
      this.editableFlag,
      this.sendableFlag,
      this.panelId,
      this.screeningId,
      this.onDone});
}

enum TestType { GoogleDoc, InApplication }

class MedicalTestItem {
  /// this model is for loading test list from database and showing theme in
  /// noronioClinicService or panel after sending to a patient
  int testId;
  TestType testType;
  String name;
  String description;
  String imageURL;
  bool done;
  String testLink;

  bool get isInAppTest {
    if (testType == TestType.InApplication) {
      return true;
    }
    return false;
  }

  bool get isGoogleDocTest {
    if (testType == TestType.GoogleDoc) {
      return true;
    }
    return false;
  }

  /// set just in case of google doc test type

  MedicalTestItem(this.testId, this.name,
      {this.description,
      this.imageURL,
      this.done,
      this.testType = TestType.InApplication});

  MedicalTestItem.fromJson(Map<String, dynamic> json) {
    testId = json['id'];
    name = utf8IfPossible(json['name']);
    description = utf8IfPossible(json['description']);

    /// TODO amir: incomplete api
    imageURL = json['logo'];
    done = json['done'] ?? false;

    /// TODO this may change for general google doc tests
    if (description == "#lifeQ") {
      testType = TestType.GoogleDoc;
      testLink = Strings.lifeQuestionerTestLink;
    } else {
      testType = TestType.InApplication;
    }
  }
}

class PanelMedicalTestItem extends MedicalTestItem {
  int id;
  int panelId;
  String timeAddTest;

  PanelMedicalTestItem(
      {this.id,
      testId,
      name,
      description,
      imageURL,
      done,
      this.panelId,
      this.timeAddTest})
      : super(testId, name,
            description: description, done: done, imageURL: imageURL);

  static PanelMedicalTestItem fromJson(Map<String, dynamic> json) {
    PanelMedicalTestItem panelMedicalTestItem = PanelMedicalTestItem();
    panelMedicalTestItem.id = intPossible(json['id']);
    panelMedicalTestItem.testId = intPossible(json['test_id']);
    panelMedicalTestItem.name = json['name'];
    panelMedicalTestItem.description = json['description'];

    /// TODO amir: incomplete api
    panelMedicalTestItem.imageURL = json['logo'];
    panelMedicalTestItem.done = json['done'] ?? false;
    panelMedicalTestItem.panelId = intPossible(json['panel_id']);
    panelMedicalTestItem.timeAddTest = json['time_add_test'];
    return panelMedicalTestItem;
  }
}

class MedicalTest {
  int id;
  String name;
  String description;
  List<Question> questions;

  MedicalTest({this.id, this.name, this.description, this.questions});

  MedicalTest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    if (json['questions'] != null) {
      questions = new List<Question>();
      json['questions'].forEach((v) {
        questions.add(new Question.fromJson(v));
      });
    }
  }

  Map<int, QuestionAnswer> get oldAnswers {
    Map<int, QuestionAnswer> res = {};
    questions.forEach((question) {
      if (question.type == QuestionType.MultipleChoice) {
        question.answers.forEach((answer) {
          if (answer.selected) {
            QuestionAnswer questionAnswer =
                QuestionAnswer(QuestionType.MultipleChoice, answer, null);
            res[question.id] = questionAnswer;
          }
        });
      } else {
        QuestionAnswer questionAnswer = QuestionAnswer(
            QuestionType.Descriptive, null, question.description);
        res[question.id] = questionAnswer;
      }
    });
    return res;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.questions != null) {
      data['questions'] = this.questions.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

enum QuestionType { Descriptive, MultipleChoice }

class Question {
  int id;
  String label;
  List<Answer> answers;
  String description;
  QuestionType type;

  Question({this.id, this.label, this.answers, this.type, this.description});

  Question.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    answers = new List<Answer>();
    if (json['type'] == 0) {
      type = QuestionType.Descriptive;
      description = utf8IfPossible(json['description']);
    } else if (json['type'] == 1) {
      type = QuestionType.MultipleChoice;

      if (json['answers'] != null) {
        json['answers'].forEach((v) {
          answers.add(new Answer.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['label'] = this.label;
    if (this.answers != null) {
      data['answers'] = this.answers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Answer {
  int id;
  String text;
  int score;
  bool selected;

  Answer({this.id, this.text, this.score});

  Answer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    score = json['score'];
    selected = json['selected'] == "selected";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['score'] = this.score;
    data['selected'] = this.selected;
    return data;
  }
}

class QuestionAnswer {
  final QuestionType type;
  final Answer answer;
  final String text;

  QuestionAnswer(this.type, this.answer, this.text);
}

//// api models
class MedicalTestResponseEntity {
  String msg;

  MedicalTestResponseEntity(this.msg);

  MedicalTestResponseEntity.fromJson(Map<String, dynamic> json) {
    msg = utf8IfPossible(json['msg']);
  }

  bool get success {
    if (msg == "نتیجه با موفقیت ذخیره شد.") {
      return true;
    }
    return false;
  }
}
