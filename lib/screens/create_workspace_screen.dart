import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/models/work_space.dart';
import 'package:hackathon/services/workspace_db_service.dart';

class CreateWorkspaceScreen extends StatelessWidget {
  CreateWorkspaceScreen({super.key});
  final _workspaceService = WorkspaceDbService();
  final _auth = FirebaseAuth.instance;
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: "createWS",
        child: Center(
          child: Container(
            height: MediaQuery.sizeOf(context).height / 3,
            width: MediaQuery.sizeOf(context).width * 0.8,
            decoration: BoxDecoration(
                color: color3,
                borderRadius: const BorderRadius.all(Radius.circular(15))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10),
                          hintText: "Çalışma alanı adı",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  height: 0,
                ),
                TextButton(
                    onPressed: () async {
                      String id =
                          "${Timestamp.now().microsecondsSinceEpoch}_${_auth.currentUser!.uid}";
                      Timestamp createdOn = Timestamp.now();
                      final ws = WorkSpace(
                          id: id,
                          name: _textController.text,
                          contributers: [_auth.currentUser!.uid],
                          createdOn: createdOn,
                          lastOpened: createdOn);
                      await _workspaceService.addWorkSpace(ws);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Oluştur",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        ));
  }
}
