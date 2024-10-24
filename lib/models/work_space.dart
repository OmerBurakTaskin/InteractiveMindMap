import 'package:cloud_firestore/cloud_firestore.dart';

class WorkSpace {
  final String _id;
  final String _name;
  final List<String> _contributersId;
  final Timestamp _createdOn;
  WorkSpace(
      {required String id,
      required String name,
      required List<String> contributersId,
      required Timestamp createdOn})
      : _id = id,
        _name = name,
        _contributersId = contributersId,
        _createdOn = createdOn;

  WorkSpace.fromJson(Map<String, dynamic> json)
      : this(
            contributersId: json["contributersId"],
            name: json["_name"],
            id: json["id"],
            createdOn: json["createdOn"]);

  Map<String, dynamic> toJson() {
    return {
      "id": _id,
      "name": _name,
      "contributersId": _contributersId,
      "createdOn": _createdOn
    };
  }

  String get id => _id;
  String get name => _name;
  List<String> get contributersId => _contributersId;
  Timestamp get createdOn => _createdOn;
}
