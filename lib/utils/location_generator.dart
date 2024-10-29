import 'dart:math';

import 'package:hackathon/models/card_location.dart';

class LocationGenerator {
  static const double MIN_DISTANCE = 300.0; // Kartlar arası minimum mesafe
  static const double IDEAL_DISTANCE = 350.0; // İdeal kart mesafesi
  static const double MAX_ATTEMPTS = 150; // Maksimum deneme sayısı

  CardLocation generateLocation(
    CardLocation parentLocation,
    List<CardLocation> existingLocations,
  ) {
    final random = Random();
    CardLocation? bestLocation;
    double bestOverlap = double.infinity;

    // Birkaç farklı açıda deneme yap
    for (int i = 0; i < MAX_ATTEMPTS; i++) {
      // Rastgele bir açı seç (0-360 derece)
      double angle = random.nextDouble() * 2 * pi;

      // Rastgele bir mesafe seç (IDEAL_DISTANCE etrafında değişken)
      double distance = IDEAL_DISTANCE + (random.nextDouble() - 0.5) * 100;

      // Yeni pozisyonu hesapla
      double newX = parentLocation.x + cos(angle) * distance;
      double newY = parentLocation.y + sin(angle) * distance;

      // Aday lokasyon
      CardLocation candidateLocation = CardLocation(x: newX, y: newY);

      // Bu lokasyonun diğer kartlarla çakışma durumunu kontrol et
      double currentOverlap = calculateTotalOverlap(
        candidateLocation,
        existingLocations,
      );

      // Eğer bu şimdiye kadarki en iyi lokasyonsa, kaydet
      if (currentOverlap < bestOverlap) {
        bestOverlap = currentOverlap;
        bestLocation = candidateLocation;

        // Eğer hiç çakışma yoksa, bu lokasyonu hemen kullan
        if (currentOverlap == 0) {
          break;
        }
      }
    }

    // Eğer uygun bir lokasyon bulunamadıysa, en az çakışan lokasyonu kullan
    return bestLocation ??
        _generateFallbackLocation(parentLocation, existingLocations);
  }

  double calculateTotalOverlap(
    CardLocation candidate,
    List<CardLocation> existingLocations,
  ) {
    double totalOverlap = 0;

    for (var location in existingLocations) {
      double distance = calculateDistance(candidate, location);

      // Eğer kartlar çok yakınsa, çakışma miktarını hesapla
      if (distance < MIN_DISTANCE) {
        totalOverlap += MIN_DISTANCE - distance;
      }
    }

    return totalOverlap;
  }

  double calculateDistance(CardLocation a, CardLocation b) {
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  CardLocation _generateFallbackLocation(
    CardLocation parentLocation,
    List<CardLocation> existingLocations,
  ) {
    // Spiralde giderek genişleyen bir arama yap
    double angle = 0;
    double distance = IDEAL_DISTANCE;
    final spiral = 0.5; // Spiral artış faktörü

    while (distance < IDEAL_DISTANCE * 3) {
      double newX = parentLocation.x + cos(angle) * distance;
      double newY = parentLocation.y + sin(angle) * distance;

      CardLocation candidateLocation = CardLocation(x: newX, y: newY);

      if (calculateTotalOverlap(candidateLocation, existingLocations) == 0) {
        return candidateLocation;
      }

      angle += pi / 6; // 30 derece artır
      distance += spiral * IDEAL_DISTANCE * (angle / (2 * pi));
    }

    // En kötü durumda, parent'ın uzağında bir yer seç
    return CardLocation(
      x: parentLocation.x + IDEAL_DISTANCE * 2,
      y: parentLocation.y + IDEAL_DISTANCE * 2,
    );
  }
}
