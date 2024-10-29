import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/models/work_space.dart';
import 'package:hackathon/providers/workspace_provider.dart';
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
  final _transformationController = WorkSpaceProvider.transformationController;
  late Future<void> _workspaceFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WorkSpaceProvider>(context, listen: false);
    _workspaceFuture = provider.initializeWorkSpace(widget.workSpace.id);
    //final center = provider.centerLocation();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context);
    final _deferredPointerLink = DeferredPointerHandlerLink();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workSpace.name),
        actions: [
          IconButton(
              onPressed: () {
                _transformationController.value = Matrix4.identity()
                  ..translate(50.0, 50.0) // Center the view initially
                  ..scale(0.5);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: DeferredPointerHandler(
        link: _deferredPointerLink,
        child: FutureBuilder(
            future: _workspaceFuture,
            builder: (context, snapshot) {
              return InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(5000),
                  minScale: 0.2,
                  maxScale: 2.0,
                  child: Stack(
                      clipBehavior: Clip.none,
                      children:
                          provider.getWorkspaceElements(_deferredPointerLink)));
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(provider.selectedMindCards.isNotEmpty
            ? Icons.auto_awesome_rounded
            : Icons.add),
        onPressed: () async {
          // deneme amaçlı
          final parent = await _workspaceDbService.getSpecificMindCard(
              _auth.currentUser!.uid,
              widget.workSpace.id,
              "U8dCaiHRNhg6FUKmV7YmcNZ25Nj1_1730198260823");
          final loc = provider.generateLocation(
              CardLocation(x: parent.locationX, y: parent.locationY));
          String id =
              "${_auth.currentUser!.uid}_${Timestamp.now().millisecondsSinceEpoch}";

          final mc = MindCard(
              id: id,
              parentId: parent.id,
              title: "Deneme3",
              subTitle: "Açıklama3",
              locationX: loc.x,
              locationY: loc.y,
              childCardIds: []);
          provider.createMindCard(
              _auth.currentUser!.uid, widget.workSpace.id, mc, parent);
        },
      ),
    );
  }

  void _showAIBar() {
    final size = MediaQuery.sizeOf(context);
    showModalBottomSheet(
      elevation: 3,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: SizedBox(
            height: size.height * 0.4,
            child: const Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    style: TextStyle(),
                    maxLines: null,
                    decoration: InputDecoration(
                      icon: Icon(Icons.auto_awesome_rounded),
                      hintText: "Selam, nasıl yardımcı olabilirim?",
                      contentPadding: EdgeInsets.only(left: 5),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
