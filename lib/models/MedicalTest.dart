import 'package:docup/models/PatientEntity.dart';
import 'package:docup/utils/Utils.dart';

class QuestionAnswerPair {
  final Question question;
  final Answer answer;

  QuestionAnswerPair(this.question, this.answer);
}

class MedicalTestResponse {
  final int patientId;
  final int cognitiveTestId;
  final Map<int, Answer> answers;

  MedicalTestResponse(this.patientId, this.cognitiveTestId, this.answers);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['patient_id'] = patientId;
    data['cognitive_test_id'] = cognitiveTestId;
    List<Map<String, dynamic>> res = [];
    List<int> questionIds = answers.keys.toList();
    questionIds.sort();
    for (int i = 0; i < questionIds.length; i++) {
      res.add({
        'question_id': questionIds[i],
        'answer_id': answers[questionIds[i]].id
      });
    }
    data['questions'] = res;
    return data;
  }
}
class MedicalTestPageData{
  final MedicalTestItem medicalTestItem;
  final PatientEntity patientEntity;
  final bool editableFlag;

  MedicalTestPageData({this.medicalTestItem, this.patientEntity, this.editableFlag});


}

class MedicalTestItem {
  /// this model is for loading test list from database and showing theme in
  /// noronioClinicService or panel after sending to a patient
  int id;
  String name;
  String description;
  String imageURL;
  bool done;

  MedicalTestItem(this.id, this.name,
      {this.description, this.imageURL, this.done});

  MedicalTestItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];

    /// TODO amir: incomplete api
    imageURL = json['imageURL'];
    done = json['done'] ?? false;
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

  Map<int, Answer> get oldAnswers {
    Map<int, Answer> res = {};
    questions.forEach((question) {
      question.answers.forEach((answer) {
        if (answer.selected) {
          res[question.id] = answer;
        }
      });
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

class Question {
  int id;
  String label;
  List<Answer> answers;

  Question({this.id, this.label, this.answers});

  Question.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    if (json['answers'] != null) {
      answers = new List<Answer>();
      json['answers'].forEach((v) {
        answers.add(new Answer.fromJson(v));
      });
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
