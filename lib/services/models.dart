import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'models.g.dart';

@JsonSerializable()
class Option {
  String value;
  String detail;
  bool correct;
  Option({this.value = '', this.detail = '', this.correct = false});
  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
  Map<String, dynamic> toJson() => _$OptionToJson(this);
}

@JsonSerializable()
class Question {
  String text;
  List<Option> options;
  Question({this.options = const [], this.text = ''});
  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

@JsonSerializable()
class Quiz {
  String id;
  String title;
  String description;
  String video;
  String topic;
  List<Question> questions;

  Quiz(
      {this.title = '',
      this.video = '',
      this.description = '',
      this.id = '',
      this.topic = '',
      this.questions = const []});
  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
  Map<String, dynamic> toJson() => _$QuizToJson(this);
}

@JsonSerializable()
class Topic {
  final String title;
  final String img;
  final String number;
  final String? website;

  Topic({
    required this.title,
    required this.img,
    required this.number,
    this.website, // This makes website optional without a default value
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

@JsonSerializable()
class Alert {
  late final String id;
  final String title;
  final String description;
  final String date;

  Alert({
    this.id = '',
    this.title = '',
    this.description = '',
    this.date = '',
  });

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
  Map<String, dynamic> toJson() => _$AlertToJson(this);
}

@JsonSerializable()
class Report {
  String uid;
  int total;
  Map topics;

  Report({this.uid = '', this.topics = const {}, this.total = 0});
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}

class UserDataProvider with ChangeNotifier {
  String name = '';
  String phoneNumber = '';

  // Initialize the values from SharedPreferences
  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? '';
    phoneNumber = prefs.getString('phoneNumber') ?? '';
    notifyListeners();
  }

  // Save the name and phone number to both provider and SharedPreferences
  void saveData(String newName, String newPhoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = newName;
    phoneNumber = newPhoneNumber;
    prefs.setString('name', name);
    prefs.setString('phoneNumber', phoneNumber);
    notifyListeners();
  }
}
