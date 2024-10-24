import 'package:flutter/material.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';

class MindCardWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final CardLocation cardLocation;
  final Color color;
  const MindCardWidget(
      {super.key,
      required this.title,
      required this.color,
      required this.subTitle,
      required this.cardLocation});
  MindCardWidget.fromMindCard(MindCard mindCard)
      : this(
            cardLocation:
                CardLocation(x: mindCard.locationX, y: mindCard.locationY),
            title: mindCard.title,
            subTitle: mindCard.subTitle,
            color: Colors.blue,
            key: Key(mindCard.id));

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: cardLocation.x - 120,
      top: cardLocation.y - 75,
      child: Container(
        height: 150,
        width: 240,
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black, offset: Offset(1, 2), blurRadius: 4)
            ]),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "roboto"),
                ),
              ),
            ),
            const Divider(
              height: 0,
              color: Colors.white,
              thickness: 2,
            ),
            Expanded(
              child: Center(
                child: Text(
                  textAlign: TextAlign.center,
                  subTitle,
                  maxLines: 3,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
