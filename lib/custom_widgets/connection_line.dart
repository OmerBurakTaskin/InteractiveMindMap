import 'package:flutter/material.dart';
import 'package:hackathon/models/card_location.dart';

class ConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double radius;
  ConnectionPainter(
      {required this.start, required this.end, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(195, 7, 7, 7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Offset controlPoint1 = Offset(start.dx + (end.dx - start.dx), start.dy);

    Offset controlPoint2 = Offset(end.dx - (end.dx - start.dx), end.dy);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ConnectionLine extends StatelessWidget {
  final CardLocation start;
  final CardLocation end;
  final double radius;
  const ConnectionLine(
      {super.key, required this.start, required this.end, this.radius = 15});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(5000, 5000),
      painter: ConnectionPainter(
          start: Offset(start.x, start.y),
          end: Offset(end.x, end.y),
          radius: radius),
    );
  }
}
