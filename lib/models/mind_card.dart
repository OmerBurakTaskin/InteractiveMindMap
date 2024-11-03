class MindCard {
  final String id;
  final String title;
  final String subTitle;
  final double locationX;
  final double locationY;
  String? parentId;
  List<String> childCardIds = [];

  MindCard(
      {required this.id,
      required this.title,
      required this.subTitle,
      required this.locationX,
      required this.locationY,
      required this.childCardIds,
      this.parentId});

  MindCard.fromJson(Map<String, dynamic> json)
      : this(
            id: json["id"],
            title: json["title"],
            subTitle: json["subTitle"],
            locationX: json["locationX"],
            locationY: json["locationY"],
            parentId: json["parentId"],
            childCardIds: List<String>.from(json["childCardIds"]));

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "subTitle": subTitle,
      "locationX": locationX,
      "locationY": locationY,
      "childCardIds": childCardIds,
      "parentId": parentId
    };
  }
}
