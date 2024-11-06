import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/providers/workspace_provider.dart';
import 'package:hackathon/services/ai_service.dart';
import 'package:hackathon/services/authentication_service.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class MindCardWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String id;
  final CardLocation cardLocation;
  final DeferredPointerHandlerLink link;
  final Color color;
  final MindCard mindCard;
  final String workspaceId;

  MindCardWidget({
    required this.mindCard,
    required this.link,
    required this.workspaceId,
    this.color = const Color(0xFF2E3192),
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
          onTap: () {
            _showAIBar(context, mindCard, workspaceId);
            provider.focusOnCard(cardLocation, MediaQuery.sizeOf(context));
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.0 + (0.05 * value),
                child: Container(
                  height: 150 + (8 * value),
                  width: 240 + (12 * value),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isSelected ? Colors.deepPurple : color1,
                        isSelected ? Colors.purple : color1,
                        isSelected ? Colors.purple : color3,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3 + 0.2 * value),
                        blurRadius: 10 + (10 * value),
                        spreadRadius: 2 + (3 * value),
                        offset: Offset(0, 4 + (2 * value)),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
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

  void _showAIBar(
      BuildContext context, MindCard selectedCard, String workspaceId) async {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    final aiService = AiService();
    // final userOccupation = Hive.box("userpersonalinfo").get("occupation");
    final userOccupation = "Software Developer";
    showModalBottomSheet(
      elevation: 3,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: SizedBox(
            height: size.height * 0.5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Text(selectedCard.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Divider(color: Colors.black),
                          Text(
                            selectedCard.subTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.black),
                          const Text("Kart önerileri:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                      future: aiService.generateSuggestions(
                          selectedCard, userOccupation),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Kişiselleştirilmiş öneriler alınıyor...",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 20),
                              CircularProgressIndicator(),
                            ],
                          ));
                        }
                        if (snapshot.hasData) {
                          final suggestions = snapshot.data;
                          return Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: suggestions!.length,
                                  itemBuilder: (context, index) {
                                    final suggestion = suggestions[index];
                                    final title = suggestion["title"]!;
                                    final subTitle = suggestion["description"]!;
                                    return ListTile(
                                      title: Text(
                                        title,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      onTap: () {
                                        final id = DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();
                                        final cardLocation = provider
                                            .generateLocation(CardLocation(
                                                x: mindCard.locationX,
                                                y: mindCard.locationY));
                                        final newCard = MindCard(
                                          id: id,
                                          parentId: selectedCard.id,
                                          childCardIds: [],
                                          title: title,
                                          subTitle: subTitle,
                                          locationX: cardLocation.x,
                                          locationY: cardLocation.y,
                                        );
                                        provider.createMindCard(
                                            AuthenticationService
                                                .auth.currentUser!.uid,
                                            workspaceId,
                                            newCard,
                                            selectedCard);
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text("Aradığınızı bulamadınız mı?"),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                child: TextField(
                                  style: TextStyle(),
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.auto_awesome_rounded),
                                    hintText: "Yapay zekaya sorunuzu sorun",
                                    contentPadding: EdgeInsets.only(left: 5),
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                        if (snapshot.hasError) {
                          if (snapshot.error.toString() ==
                              "Resource has been exhausted (e.g. check quota).") {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "Art arda çok fazla talep yapıldı. Lütfen daha sonra tekrar deneyin.",
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ));
                          }
                        }
                        return const Center(
                            child: Text(
                                "Bir hata oluştu, daha sonra tekrar deneyin."));
                      }),
                ],
              ),
            ),
          ),
        );
      },
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
