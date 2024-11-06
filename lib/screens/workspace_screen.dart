import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/screens/view_summary_screen.dart';
import 'package:hackathon/services/authentication_service.dart';
import 'package:hackathon/widgets/grid_background.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/models/quiz.dart';
import 'package:hackathon/models/work_space.dart';
import 'package:hackathon/providers/workspace_provider.dart';
import 'package:hackathon/screens/quiz_screen.dart';
import 'package:hackathon/services/ai_service.dart';
import 'package:hackathon/services/workspace_db_service.dart';
import 'package:provider/provider.dart';

class WorkspaceScreen extends StatefulWidget {
  final WorkSpace workSpace;
  const WorkspaceScreen({super.key, required this.workSpace});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final _auth = FirebaseAuth.instance;
  final _workspaceDbService = WorkspaceDbService();
  late TransformationController _transformationController;
  late Future<void> _workspaceFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    _transformationController = provider.getTransformationController;
    _workspaceFuture = provider.initializeWorkSpace(widget.workSpace.id);
    //final center = provider.centerLocation();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context);
    final _deferredPointerLink = DeferredPointerHandlerLink();
    //final size = MediaQuery.sizeOf(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.workSpace.name),
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           provider.focusOnCard(CardLocation(x: 50, y: 50), size);
      //         },
      //         icon: const Icon(Icons.add))
      //   ],
      // ),
      body: DeferredPointerHandler(
        link: _deferredPointerLink,
        child: FutureBuilder(
            future: _workspaceFuture,
            builder: (context, snapshot) {
              return Stack(
                children: [
                  const GridBackground(
                    gridSize: 20,
                  ),
                  InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(5000),
                    minScale: 0.2,
                    maxScale: 2.0,
                    child: Stack(
                        clipBehavior: Clip.none,
                        children: provider.getWorkspaceElements(
                            _deferredPointerLink, widget.workSpace.id)),
                  ),
                ],
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: provider.isAnySelected
              ? () {
                  _showSelectedCardChoices();
                }
              : () async {
                  await _createMotherMindCard(context);
                },
          child: Icon(
              provider.isAnySelected ? Icons.auto_awesome_rounded : Icons.add)),
    );
  }

  void _showSelectedCardChoices() {
    //quiz ve özet oluştur seçenekleri
    final aiService = AiService();
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    final selectedMindCards = provider.getSelectedMindCardsasMindCard;
    showModalBottomSheet(
      elevation: 3,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: SizedBox(
            height: 200,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    "Seçilen kartlar üzerinde yapmak istediğiniz işlemi seçin:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                _showChoicesButton(() async {
                  _showPreparingDialog("Quiz hazırlanıyor...");
                  Quiz? quiz = await aiService.generateQuiz(
                      selectedMindCards, "Software Developer");
                  if (quiz == null) {
                    Navigator.pop(context); //dialog kapat
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quiz oluşturulamadı.")));
                    return;
                  }
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuizScreen(quiz: quiz)));
                }, Icons.school_rounded, "Yapay Zeka Quiz Oluştur"),
                _showChoicesButton(() async {
                  _showPreparingDialog("Özet hazırlanıyor...");
                  final summary = await aiService.generateSummary(
                      selectedMindCards, "Software Developer");
                  Navigator.pop(context); //dialog kapat
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ViewSummaryScreen(summary: summary)));
                }, Icons.summarize, "Yapay Zeka Özet Oluştur"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _showChoicesButton(
      Function onPressed, IconData icon, String buttonText) {
    return TextButton(
      onPressed: () {
        onPressed();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon),
          Text(
            buttonText,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showPreparingDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (bool value) => false,
          child: AlertDialog(
            content: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(title,
                      style: TextStyle(
                          color: color3,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createMotherMindCard(BuildContext context) async {
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    final aiService = AiService();
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(3)),
                ),
                SizedBox(height: 20),
                const Text(
                  "Yapay zekanın size yadımcı olabilmesi için takıldığını konu veya soruyu belirtin. İstediğiniz cevap şeklini de ayrıca belirtebilirsiniz.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  minLines: 3,
                  maxLines: 15,
                  controller: controller,
                  decoration: InputDecoration(
                    hintText:
                        "Bana present perfect tense hakkında özet ve 3-4 tane örnek cümle verir misin?",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.auto_awesome_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Lütfen bir konu belirtin."),
                        ),
                      );
                      return;
                    }
                    final motherMindCard = await aiService.createMotherMindCard(
                      controller.text.trim(),
                      "Software Developer",
                    );
                    if (motherMindCard == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Yapay zeka cevap oluşturamadı."),
                        ),
                      );
                      return;
                    }
                    provider.createMindCard(AuthenticationService.user!.uid,
                        widget.workSpace.id, motherMindCard, null);
                    provider.focusOnCard(
                        CardLocation(
                            x: motherMindCard.locationX,
                            y: motherMindCard.locationY),
                        MediaQuery.sizeOf(context));
                    Navigator.pop(context);
                  },
                  child: const Text("Oluştur"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
