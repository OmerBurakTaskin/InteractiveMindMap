class User {
  String _name;
  String _surName;
  String _userName;
  String _userId;
  String _email;
  int age = 0;
  String occupation = "";
  String interest = "";
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

  User.allAttributes(
      {required String name,
      required String surName,
      required String userName,
      required String userId,
      required String email,
      required int age,
      required String occupation,
      required String interest,
      required List<String> friends})
      : _name = name,
        _surName = surName,
        _userName = userName,
        _email = email,
        _userId = userId,
        age = age,
        occupation = occupation,
        interest = interest,
        friends = friends;

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
