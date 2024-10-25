import 'package:cloud_firestore/cloud_firestore.dart';

class WorkSpace {
  final String _id;
  final String _name;
  final List<String> _contributers;
  final Timestamp _createdOn;
  final Timestamp _lastOpened;
  WorkSpace(
      {required String id,
      required String name,
      required List<String> contributers,
      required Timestamp createdOn,
      required Timestamp lastOpened})
      : _id = id,
        _name = name,
        _contributers = contributers,
        _createdOn = createdOn,
        _lastOpened = lastOpened;

  WorkSpace.fromJson(Map<String, dynamic> json)
      : this(
            contributers: List<String>.from(json["contributers"]),
            name: json["name"],
            id: json["id"],
            createdOn: json["createdOn"],
            lastOpened: json["lastOpened"]);

  Map<String, dynamic> toJson() {
    return {
      "id": _id,
      "name": _name,
      "contributers": _contributers,
      "createdOn": _createdOn,
      "lastOpened": _lastOpened
    };
  }

  String get id => _id;
  String get name => _name;
  List<String> get contributers => _contributers;
  Timestamp get createdOn => _createdOn;
  Timestamp get lastOpened => _lastOpened;
}
