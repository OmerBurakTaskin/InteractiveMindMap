import 'package:hackathon/models/work_space.dart';

class User {
  String _name;
  String _surName;
  String _userName;
  List<WorkSpace> workSpaces = [];

  User(
      {required String name, required String surName, required String userName})
      : _name = name,
        _surName = surName,
        _userName = userName;

  User.fromJson(Map<String, dynamic> json)
      : this(
            name: json['name'],
            surName: json['surName'],
            userName: json['userName']);

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'surName': _surName,
      'userName': _userName,
      'workSpaces': workSpaces
    };
  }

  String get name => _name;
  String get surName => _surName;
  String get userName => _userName;
}
