import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';

class GridBackground extends StatelessWidget {
  final double gridSize;

  const GridBackground({super.key, this.gridSize = 40.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(gridSize: gridSize),
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final Paint gridPaint;

  GridPainter({this.gridSize = 40.0})
      : gridPaint = Paint()
          ..color = skinColor.withOpacity(0.3) // Kare çizgilerinin rengi
          ..strokeWidth = 1.0; // Çizgilerin kalınlığı

  @override
  void paint(Canvas canvas, Size size) {
    // Yatay ve dikey çizgileri çiz
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
