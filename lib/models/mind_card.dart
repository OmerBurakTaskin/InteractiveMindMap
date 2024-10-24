class MindCard {
  final String id;
  final String title;
  final String subTitle;
  final double locationX;
  final double locationY;
  List<String> childCardIds = [];

  MindCard(
      {required this.id,
      required this.title,
      required this.subTitle,
      required this.locationX,
      required this.locationY,
      required this.childCardIds});

  MindCard.fromJson(Map<String, dynamic> json)
      : this(
            id: json["id"],
            title: json["title"],
            subTitle: json["subTitle"],
            locationX: json["locationX"],
            locationY: json["locationY"],
            childCardIds: json["childCardIds"]);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "subTitle": subTitle,
      "locationX": locationX,
      "locationY": locationY,
      "childCardIds": childCardIds
    };
  }
}
