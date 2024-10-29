import 'package:defer_pointer/defer_pointer.dart';
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
  final DeferredPointerHandlerLink link;
  final Color color;

  MindCardWidget({
    required MindCard mindCard,
    required this.link,
    this.color = const Color(0xFF2E3192), // Deep blue as default
  })  : title = mindCard.title,
        subTitle = mindCard.subTitle,
        id = mindCard.id,
        cardLocation =
            CardLocation(x: mindCard.locationX, y: mindCard.locationY),
        super(key: Key(mindCard.id));

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context);
    final isSelected = provider.isSelected(id);

    return Positioned(
      left: cardLocation.x - 120,
      top: cardLocation.y - 75,
      child: DeferPointer(
        link: link,
        child: GestureDetector(
          onLongPress: () => provider.toggleMindCardSelection(id),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.0 + (0.05 * value),
                child: Container(
                  height: 150 + (20 * value),
                  width: 240 + (30 * value),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withOpacity(1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10 + (10 * value),
                        spreadRadius: 2 + (3 * value),
                        offset: Offset(0, 4 + (2 * value)),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PatternPainter(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                        ),
                        // Content
                        Column(
                          children: [
                            Container(
                              height: 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Center(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18 + (3 * value),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Container(
                              height: 2,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.6),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  subTitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14 + (3 * value),
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double spacing = 20.0;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(-size.height + i, size.height),
        Offset(i, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
