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
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium_outlined,
                      size: 64, color: color1.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text("Çalışma alanı bulunamadı",
                      style: TextStyle(
                          fontSize: 18,
                          color: color1,
                          fontWeight: FontWeight.w500)),
                ],
              ));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: workSpaces.length,
                itemBuilder: (context, index) {
                  final ws = workSpaces[index];
                  final wsLastOpen = ws.lastOpened.toDate();

                  return InkWell(
                    onTap: () async {
                      await _workSpaceService.updateLastChange(
                          AuthenticationService.user!.uid, ws.id);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkspaceScreen(workSpace: ws),
                          ));
                    },
                    onLongPress: () {
                      _dialogBuilder(context, _auth.currentUser!.uid, ws.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color2.withOpacity(0.9),
                            color3,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: color3.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Background Pattern
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Workspace Name
                                  Text(
                                    ws.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),

                                  // Last Modified Date
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: color4,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${wsLastOpen.day}/${wsLastOpen.month}/${wsLastOpen.year}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: color4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // Loading State
          return Center(
            child: CircularProgressIndicator(
              color: color1,
            ),
          );
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
