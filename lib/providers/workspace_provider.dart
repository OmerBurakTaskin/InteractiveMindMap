import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_widgets/connection_line.dart';
import 'package:hackathon/custom_widgets/mind_card.dart';
import 'package:hackathon/models/card_location.dart';
import 'package:hackathon/models/mind_card.dart';
import 'package:hackathon/services/workspace_db_service.dart';
import 'package:hackathon/utils/location_generator.dart';

class WorkSpaceProvider extends ChangeNotifier {
  final _workSpaceDbService = WorkspaceDbService();
  final _transformationController = TransformationController();

  Set<Set<String>> _selectedMindCards = {};
  List<MindCard> _mindCards = [];
  List<Widget> _connectionLines = [];
  List<CardLocation> _cardLocations = [];
  bool isSelected(String id) => getSelectedMindCards.contains(id);
  bool get isAnySelected => _selectedMindCards.isNotEmpty;
  TransformationController get getTransformationController =>
      _transformationController;
  List<MindCard> get getMindCards => _mindCards;
  List<Widget> get getConnectionLines => _connectionLines;

  List<Widget> getWorkspaceElements(
          DeferredPointerHandlerLink link, String workspaceId) =>
      [
        ..._connectionLines,
        ..._mindCards.map((mindCard) => MindCardWidget(
              mindCard: mindCard,
              link: link,
              workspaceId: workspaceId,
              color: Colors.indigo,
            ))
      ];

  CardLocation centerLocation() {
    double x = 0;
    double y = 0;
    for (MindCard card in _mindCards) {
      x += card.locationX;
      y += card.locationY;
    }
    return CardLocation(x: x / _mindCards.length, y: y / _mindCards.length);
  }

  void _addNewMindCard(MindCard parentCard, MindCard newCard) {
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
    final List<Widget> connectionLines = [];
    for (var card in mindCards) {
      for (String id in card.childCardIds) {
        final child = cardMap[id];
        if (child != null) {
          connectionLines.add(ConnectionLine(
              start: CardLocation(x: card.locationX, y: card.locationY),
              end: CardLocation(x: child.locationX, y: child.locationY)));
        }
      }
    }
    _connectionLines = connectionLines;
    notifyListeners();
  }

  // CardLocation generateLocation(CardLocation parentLocation) {
  //   final random = Random();
  //   int directionx = random.nextInt(2) * 2 - 1; // x'te yön belirle -1 ya da 1
  //   int margin = random.nextInt(30);
  //   double x = parentLocation.x + directionx * 270; //x'te 30 margin oluştur
  //   int counter = 1; // parentın etrafı çok dolu mu kontrol etmek için
  //   while (_cardLocations.any(
  //       (location) => (location.x - (x + directionx * margin)).abs() < 300)) {
  //     margin = random.nextInt(30 * (counter / 100).ceil());
  //     counter++; // her 20 seferde alanı arttırır.
  //   }
  //   x += margin;
  //   // Y IŞLEMLERI
  //   int directiony = random.nextInt(2) * 2 - 1; //y'de yön belirle -1 ya da 1
  //   margin = random.nextInt(30);
  //   double y = parentLocation.x +
  //       directiony * random.nextInt(30) +
  //       directiony * 180; //y'de 30 ila 60 margin oluştur
  //   counter = 1;
  //   while (_cardLocations.any(
  //       (location) => (location.y - (y + directiony * margin)).abs() < 180)) {
  //     margin = random.nextInt(30 * (counter / 100).ceil());
  //     counter++; // her 20 seferde bir alanı arttırır.
  //   }
  //   y += margin;
  //   return CardLocation(x: x, y: y);
  // }

  CardLocation generateLocation(CardLocation parentLocation) {
    final generator = LocationGenerator();
    return generator.generateLocation(parentLocation, _cardLocations);
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
      _addNewMindCard(parent, newCard); // ekleme işlemi
    }
    notifyListeners();
  }

  Set<String> getChain(String cardId) {
    //başlangıçtan tıklanan karta olan kartların idlerini getirir.
    Set<String> chain = {};
    String? currentCard = cardId;
    while (currentCard != null) {
      for (MindCard mc in _mindCards) {
        if (mc.id == currentCard) {
          chain.add(mc.id);
          currentCard = mc.parentId; //parent null olana kadar ilerle
        }
      }
    }
    return chain;
  }

  Set<String> get getSelectedMindCards {
    Set<String> selectedCards = {};
    for (Set<String> chain in _selectedMindCards) {
      selectedCards.addAll(chain);
    }
    return selectedCards;
  }

  void toggleMindCardSelection(String cardId) {
    final selectedChain = getChain(cardId);
    for (Set<String> chain in _selectedMindCards) {
      if (setEquals(chain, selectedChain)) {
        _selectedMindCards.remove(chain);
        notifyListeners();
        return;
      }
    }
    _selectedMindCards.add(selectedChain);
    notifyListeners();
  }

  void focusOnCard(CardLocation location, Size screenSize) async {
    _transformationController.value = Matrix4.identity()
      ..translate(screenSize.width / 2 - location.x,
          screenSize.height / 2 - location.y - 250)
      ..scale(1.0);
  }
}
