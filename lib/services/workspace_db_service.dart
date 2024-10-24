import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/models/work_space.dart';

class WorkspaceDbService {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  Future<void> addWorkSpace(WorkSpace workSpace) async {
    final userId = _auth.currentUser!.uid;
    _fireStore
        .collection("users/$userId/workspaces")
        .doc(workSpace.id)
        .set(workSpace.toJson());
  }

  Future<WorkSpace?> getWorkSpace(String userId, String workSpaceId) async {
    try {
      final doc = await _fireStore
          .collection("users/$userId/workspaces")
          .doc(workSpaceId)
          .get();
      return WorkSpace.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("WORKSPACE GETIRME HATASI : $e");
    }
    return null;
  }

  Stream<List<WorkSpace>> getWorkSpaces(String userId) {
    return _fireStore.collection("users/$userId/workspaces").snapshots().map(
        (event) =>
            event.docs.map((e) => WorkSpace.fromJson(e.data())).toList());
  }

  Future<void> addMindCard(
      String userId, String workSpaceId, MindCard mindCard) async {
    await _fireStore
        .collection("users/$userId/workspaces/$workSpaceId/mindcards")
        .add(mindCard.toJson());
  }

  Future<List<MindCard>> getMindCards(String workSpaceId) async {
    final userId = _auth.currentUser!.uid;
    final mindCardDocs = await _fireStore
        .collection("users/$userId/workspaces/$workSpaceId/mindcards")
        .get();
    return mindCardDocs.docs.map((e) => MindCard.fromJson(e.data())).toList();
  }

  Future<void> deleteMindCard(
      String userId, String workSpaceId, String mindCardId) async {
    await _fireStore
        .collection("users/$userId/workspaces/$workSpaceId/mindcards")
        .doc(mindCardId)
        .delete();
  }

  Future<void> updateMindCard(MindCard mindCard, String workSpaceId) async {
    final userId = _auth.currentUser!.uid;
    await _fireStore
        .collection("users/$userId/workspaces/$workSpaceId")
        .doc(mindCard.id)
        .update({"childCardIds": mindCard.childCardIds});
  }

  Future<void> deleteWorkSpace(String userId, String workSpaceId) async {
    await _fireStore
        .collection("users/$userId/workspaces")
        .doc(workSpaceId)
        .delete();
  }
}
