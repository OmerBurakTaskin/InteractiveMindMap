import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hackathon/models/card_location.dart';

class ConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double radius;
  final double progress;
  final bool showArrow;

  ConnectionPainter({
    required this.start,
    required this.end,
    required this.radius,
    required this.progress,
    this.showArrow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gradient için shader oluştur
    const gradient = LinearGradient(
      colors: [
        Color(0xFF2E3192), // Başlangıç rengi
        Color(0xFF1BFFFF), // Bitiş rengi
      ],
    );

    // Path'i oluştur
    final path = createCurvePath();

    // Gradient paint
    final gradientPaint = Paint()
      ..shader = gradient.createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glow efekti için
    final glowPaint = Paint()
      ..shader = gradient.createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // Animasyon için PathMetrics kullan
    final PathMetric pathMetric = path.computeMetrics().first;
    final double length = pathMetric.length;

    // Animasyonlu path çizimi
    final Path animatedPath = Path();
    for (double i = 0; i < length * progress; i += 1) {
      try {
        final pos = pathMetric.getTangentForOffset(i);
        if (pos != null) {
          if (i == 0) {
            animatedPath.moveTo(pos.position.dx, pos.position.dy);
          } else {
            animatedPath.lineTo(pos.position.dx, pos.position.dy);
          }
        }
      } catch (e) {
        // Handle any potential errors during path creation
      }
    }

    // Önce glow efektini çiz
    canvas.drawPath(animatedPath, glowPaint);
    // Sonra ana çizgiyi çiz
    canvas.drawPath(animatedPath, gradientPaint);

    // Ok başı çizimi

    // Yol üzerinde hareket eden nokta efekti
    if (progress > 0.1) {
      drawMovingDot(canvas, pathMetric, length, progress);
    }
  }

  Path createCurvePath() {
    final path = Path();
    final midX = (start.dx + end.dx) / 2;

    final controlPoint1 = Offset(midX, start.dy);
    final controlPoint2 = Offset(midX, end.dy);

    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    return path;
  }

  void drawMovingDot(
      Canvas canvas, PathMetric pathMetric, double length, double progress) {
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pos = pathMetric.getTangentForOffset(length * progress);
    if (pos != null) {
      canvas.drawCircle(pos.position, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.start != start ||
        oldDelegate.end != end;
  }
}

class ConnectionLine extends StatefulWidget {
  final CardLocation start;
  final CardLocation end;
  final double radius;

  const ConnectionLine({
    super.key,
    required this.start,
    required this.end,
    this.radius = 15,
  });

  @override
  State<ConnectionLine> createState() => _ConnectionLineState();
}

class _ConnectionLineState extends State<ConnectionLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(5000, 5000),
          painter: ConnectionPainter(
            start: Offset(widget.start.x, widget.start.y),
            end: Offset(widget.end.x, widget.end.y),
            radius: widget.radius,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}
