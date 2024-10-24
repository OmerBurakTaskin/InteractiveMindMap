import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_widgets/connection_line.dart';
import 'package:hackathon/custom_widgets/mind_card.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/services/workspace_db_service.dart';

class WorkSpaceProvider extends ChangeNotifier {
  final _workSpaceDbService = WorkspaceDbService();

  List<Widget> _mindCards = [];
  List<Widget> _connectionLines = [];
  List<CardLocation> _cardLocations = [];
  List<Widget> get getMindCards => _mindCards;
  List<Widget> get getConnectionLines => _connectionLines;
  List<Widget> get getWorkspaceElements => [..._connectionLines, ..._mindCards];

  void addNewMindCard(MindCardWidget parentCard, MindCardWidget newCard) {
    final newConnection = ConnectionLine(
        start: parentCard.cardLocation, end: newCard.cardLocation);
    _cardLocations.add(newCard.cardLocation);
    _mindCards.add(newCard);
    _connectionLines.add(newConnection);
    notifyListeners();
  }

  Future<void> initializeWorkSpace(String workSpaceId) async {
    final mindCardModels = await _workSpaceDbService.getMindCards(workSpaceId);

    Map<String, MindCard> cardMap = {
      for (var card in mindCardModels) card.id: card
    };

    _mindCards = mindCardModels.map((e) {
      final cardlocation = CardLocation(x: e.locationX, y: e.locationY);
      _cardLocations.add(cardlocation);
      return MindCardWidget(
          title: e.title,
          color: Colors.blue,
          subTitle: e.subTitle,
          cardLocation: cardlocation);
    }).toList();

    for (var card in mindCardModels) {
      for (String id in card.childCardIds) {
        final child = cardMap[id];
        if (child != null) {
          _connectionLines.add(ConnectionLine(
              start: CardLocation(x: card.locationX, y: card.locationY),
              end: CardLocation(x: child.locationX, y: child.locationY)));
        }
      }
    }
    notifyListeners();
  }

  CardLocation generateLocation(MindCardWidget parent) {
    final parentLocation = parent.cardLocation;
    final random = Random();
    int direction = random.nextInt(1) * 2 - 1; // x'te yön belirle -1 ya da 1
    int margin = random.nextInt(30);
    double x = parentLocation.x +
        direction * random.nextInt(30) +
        direction * 150; //x'te 30 ila 60 margin oluştur
    int counter = 1; // parentın etrafı çok dolu mu kontrol etmek için
    while (_cardLocations.any(
        (location) => (location.x - (x + direction * margin)).abs() < 30)) {
      margin = random.nextInt(30 * (counter / 20).ceil());
      counter++; // her 20 seferde alanı arttırır.
    }
    x += margin;
    // Y IŞLEMLERI
    direction = random.nextInt(1) * 2 - 1; //y'de yön belirle -1 ya da 1
    margin = random.nextInt(30);
    double y = parentLocation.x +
        direction * random.nextInt(30) +
        direction * 110; //y'de 30 ila 60 margin oluştur
    counter = 1;
    while (_cardLocations.any(
        (location) => (location.y - (y + direction * margin)).abs() < 30)) {
      margin = random.nextInt(30 * (counter / 20).ceil());
      counter++; // her 20 seferde bir alanı arttırır.
    }
    y += margin;
    return CardLocation(x: x, y: y);
  }

  Future<void> createMindCard(String userId, String workSpaceId,
      MindCard newCard, MindCard? parent) async {
    await _workSpaceDbService.addMindCard(userId, workSpaceId, newCard);
    if (parent == null) {
      // parent yok, bağlantı yok, direk ekle
      final card = MindCardWidget.fromMindCard(newCard);
      _mindCards.add(card);
    } else {
      parent.childCardIds.add(newCard.id); // parentı firestoreda güncelle
      await _workSpaceDbService.updateMindCard(parent, workSpaceId);
      addNewMindCard(MindCardWidget.fromMindCard(parent),
          MindCardWidget.fromMindCard(newCard)); // ekleme işlemi
    }
    notifyListeners();
  }
}
