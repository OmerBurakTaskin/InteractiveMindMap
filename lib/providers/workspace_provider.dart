import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_widgets/connection_line.dart';
import 'package:hackathon/custom_widgets/mind_card.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/services/workspace_db_service.dart';

class WorkSpaceProvider extends ChangeNotifier {
  final _workSpaceDbService = WorkspaceDbService();
  static final transformationController = TransformationController();

  List<MindCard> _mindCards = [];
  List<Widget> _connectionLines = [];
  List<CardLocation> _cardLocations = [];
  List<MindCard> get getMindCards => _mindCards;
  List<Widget> get getConnectionLines => _connectionLines;
  List<Widget> get getWorkspaceElements => [
        ..._connectionLines,
        ..._mindCards.map((mindCard) => MindCardWidget.fromMindCard(mindCard))
      ];

  static void moveFocusTo(CardLocation cardLocation) {
    transformationController.value = Matrix4.identity()
      ..translate(cardLocation.x, cardLocation.y);
  }

  MindCard? getMindCardWithId(String id) {
    for (MindCard mindCard in _mindCards) {
      if (mindCard.id == id) {
        return mindCard;
      }
    }
    return null;
  }

  void addNewMindCard(MindCard parentCard, MindCard newCard) {
    final newConnection = ConnectionLine(
        start: CardLocation(x: parentCard.locationX, y: parentCard.locationY),
        end: CardLocation(x: newCard.locationX, y: newCard.locationY));
    _cardLocations
        .add(CardLocation(x: newCard.locationX, y: newCard.locationY));
    _mindCards.add(newCard);
    _connectionLines.add(newConnection);
    notifyListeners();
  }

  Future<void> initializeWorkSpace(String workSpaceId) async {
    final mindCards = await _workSpaceDbService.getMindCards(workSpaceId);

    Map<String, MindCard> cardMap = {for (var card in mindCards) card.id: card};

    _mindCards = mindCards;

    for (var card in mindCards) {
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

  CardLocation generateLocation(CardLocation parentLocation) {
    final random = Random();
    int directionx = random.nextInt(2) * 2 - 1; // x'te yön belirle -1 ya da 1
    int margin = random.nextInt(30);
    double x = parentLocation.x + directionx * 270; //x'te 30 margin oluştur
    int counter = 1; // parentın etrafı çok dolu mu kontrol etmek için
    while (_cardLocations.any(
        (location) => (location.x - (x + directionx * margin)).abs() < 300)) {
      margin = random.nextInt(30 * (counter / 100).ceil());
      counter++; // her 20 seferde alanı arttırır.
    }
    x += margin;
    // Y IŞLEMLERI
    int directiony = random.nextInt(2) * 2 - 1; //y'de yön belirle -1 ya da 1
    margin = random.nextInt(30);
    double y = parentLocation.x +
        directiony * random.nextInt(30) +
        directiony * 180; //y'de 30 ila 60 margin oluştur
    counter = 1;
    while (_cardLocations.any(
        (location) => (location.y - (y + directiony * margin)).abs() < 180)) {
      margin = random.nextInt(30 * (counter / 100).ceil());
      counter++; // her 20 seferde bir alanı arttırır.
    }
    y += margin;
    return CardLocation(x: x, y: y);
  }

  Future<void> createMindCard(String userId, String workSpaceId,
      MindCard newCard, MindCard? parent) async {
    await _workSpaceDbService.addMindCard(userId, workSpaceId, newCard);
    if (parent == null) {
      // parent yok, bağlantı yok, direkt ekle
      _mindCards.add(newCard);
    } else {
      parent.childCardIds.add(newCard.id); // parentı firestoreda güncelle
      await _workSpaceDbService.updateMindCard(parent, workSpaceId);
      addNewMindCard(parent, newCard); // ekleme işlemi
    }
    notifyListeners();
  }

  void getChain(String cardId) {
    //başlangıçtan tıklanan karta olan kartların idlerini getirir.
    List<MindCard> chain = [];
    String? currentCard = cardId;
    while (currentCard != null) {
      for (MindCard mc in _mindCards) {
        if (mc.id == cardId) {
          chain.add(mc);
          currentCard = mc.parentId; //parent null olana kadar ilerle
        }
      }
    }
  }
}
