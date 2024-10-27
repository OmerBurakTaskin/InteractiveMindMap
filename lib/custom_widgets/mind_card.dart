import 'package:flutter/material.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/providers/workspace_provider.dart';
import 'package:provider/provider.dart';

class MindCardWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String id;
  final CardLocation cardLocation;
  final Color color;

  MindCardWidget({
    required MindCard mindCard,
  })  : title = mindCard.title,
        subTitle = mindCard.subTitle,
        id = mindCard.id,
        cardLocation =
            CardLocation(x: mindCard.locationX, y: mindCard.locationY),
        color = Colors.blue,
        super(key: Key(mindCard.id));

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context);
    final isSelected = provider.isSelected(id);

    // Calculate position relative to the center of the large container
    // final centerOffset =
    //     10000.0; // Half of the SizedBox size from BoundlessInteractionStack

    return Positioned(
      left: cardLocation.x - 120,
      top: cardLocation.y - 75,
      child: GestureDetector(
        behavior: HitTestBehavior
            .opaque, // This ensures the gesture detector catches all touches
        onTapDown: (_) {
          print("Tap detected"); // Debug print
        },
        onLongPress: () {
          print("Long press detected"); // Debug print
          provider.toggleMindCardSelection(id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isSelected ? 170 : 150,
          width: isSelected ? 270 : 240,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: isSelected ? 5 : 2,
                blurRadius: isSelected ? 10 : 5,
              ),
            ],
          ),
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
                      fontFamily: "roboto",
                    ),
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
      ),
    );
  }
}
