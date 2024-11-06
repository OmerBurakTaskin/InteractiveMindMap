import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/widgets/hero_dialog_route.dart';
import 'package:hackathon/models/work_space.dart';
import 'package:hackathon/screens/create_workspace_screen.dart';
import 'package:hackathon/screens/workspace_screen.dart';
import 'package:hackathon/services/authentication_service.dart';
import 'package:hackathon/services/workspace_db_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _workSpaceService = WorkspaceDbService();
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: _workSpaceService.getAllWorkSpaces(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final workSpaceDocs = snapshot.data!.docs;
            final workSpaces = workSpaceDocs
                .map((e) =>
                    WorkSpace.fromJson(e.data()! as Map<String, dynamic>))
                .toList();
            if (workSpaces.isEmpty) {
              return const Center(
                  child: Text("Çalışma alanı bulunamadı",
                      style: TextStyle(fontSize: 18)));
            }
            return ListView.builder(
              itemCount: workSpaces.length,
              itemBuilder: (context, index) {
                final ws = workSpaces[index];
                final wsLastOpen = ws.lastOpened.toDate();
                return ListTile(
                  title: Text(
                    ws.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: color3),
                  ),
                  subtitle: Text(
                    "Son değiştirilme: ${wsLastOpen.day}/${wsLastOpen.month}/${wsLastOpen.year}",
                    style: TextStyle(color: color1),
                  ),
                  onTap: () async {
                    await _workSpaceService.updateLastChange(
                        AuthenticationService.user!.uid, ws.id);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkspaceScreen(workSpace: ws),
                        ));
                  },
                  onLongPress: () {
                    _dialogBuilder(context, _auth.currentUser!.uid, ws.id);
                  },
                );
              },
            );
          }
          return const Center(
              child: Text(
            "Çalışma alanı bulunamadı",
            style: TextStyle(fontSize: 18),
          ));
        },
      ),
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, String userId, String workSpaceId) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çalışma alanı silinsin mi?'),
          content: const Text(
            "Silinen çalışmalar geri getirilemez.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Sil'),
              onPressed: () async {
                await _workSpaceService.deleteWorkSpace(userId, workSpaceId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _addWSButton() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return CreateWorkspaceScreen();
          }));
        },
        child: Hero(
          tag: "createWS",
          child: Material(
            color: color3,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
