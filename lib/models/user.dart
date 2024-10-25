import 'package:hackathon/models/work_space.dart';

class User {
  String _name;
  String _surName;
  String _userName;
  String _userId;
  String _email;
  List<String> friends = []; //friend idleri tutar

  User(
      {required String name,
      required String surName,
      required String userName,
      required String userId,
      required String email})
      : _name = name,
        _surName = surName,
        _userName = userName,
        _email = email,
        _userId = userId;

  User.fromJson(Map<String, dynamic> json)
      : this(
            name: json['name'],
            surName: json['surName'],
            userName: json['userName'],
            email: json['email'],
            userId: json["userId"]);

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'surName': _surName,
      'userName': _userName,
      'friends': friends,
      'email': _email,
      "userId": _userId
    };
  }

  String get name => _name;
  String get surName => _surName;
  String get userName => _userName;
  String get email => _email;
  String get userId => _userId;
}
