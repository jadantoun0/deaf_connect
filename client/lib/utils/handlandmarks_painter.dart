import 'package:deafconnect/utils/colors.dart';
import 'package:flutter/material.dart';

class HandLandmarksPainter extends CustomPainter {
  final List<dynamic> handLandmarks;
  final String prediction;
  final double confidence;
  final bool drawLandmarks;

  HandLandmarksPainter({
    required this.handLandmarks,
    required this.prediction,
    required this.confidence,
    required this.drawLandmarks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 5;
    final circlePaint = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    final skeletonIndices = [
      [
        [0, 1],
        Colors.white
      ],
      [
        [1, 2],
        Colors.white
      ],
      [
        [2, 3],
        Colors.white
      ],
      [
        [3, 4],
        Colors.white
      ],
      [
        [5, 6],
        Colors.purple
      ],
      [
        [6, 7],
        Colors.purple
      ],
      [
        [7, 8],
        Colors.purple
      ],
      [
        [9, 10],
        Colors.yellow
      ],
      [
        [10, 11],
        Colors.yellow
      ],
      [
        [11, 12],
        Colors.yellow
      ],
      [
        [13, 14],
        Colors.green
      ],
      [
        [14, 15],
        Colors.green
      ],
      [
        [15, 16],
        Colors.green
      ],
      [
        [17, 18],
        Colors.blue
      ],
      [
        [18, 19],
        Colors.blue
      ],
      [
        [19, 20],
        Colors.blue
      ],
      [
        [0, 5],
        Colors.red
      ],
      [
        [5, 9],
        Colors.red
      ],
      [
        [9, 13],
        Colors.red
      ],
      [
        [13, 17],
        Colors.red
      ],
      [
        [0, 17],
        Colors.red
      ],
    ];

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var landmarks in handLandmarks) {
      List<dynamic> serializedLandmarks = landmarks as List<dynamic>;
      for (var skeletonInfo in skeletonIndices) {
        List<dynamic> indices = skeletonInfo[0] as List<dynamic>;
        Color color = skeletonInfo[1] as Color;
        paint.color = color;

        double startX = (1 - serializedLandmarks[indices[0]]['x']) * size.width;
        double startY = serializedLandmarks[indices[0]]['y'] * size.height - 50;
        Offset start = Offset(startX, startY);

        double endX = (1 - serializedLandmarks[indices[1]]['x']) * size.width;
        double endY = serializedLandmarks[indices[1]]['y'] * size.height - 50;
        Offset end = Offset(endX, endY);

        minX = [minX, startX, endX].reduce((a, b) => a < b ? a : b);
        maxX = [maxX, startX, endX].reduce((a, b) => a > b ? a : b);
        minY = [minY, startY, endY].reduce((a, b) => a < b ? a : b);
        maxY = [maxY, startY, endY].reduce((a, b) => a > b ? a : b);

        if (drawLandmarks) {
          canvas.drawLine(start, end, paint);

          canvas.drawCircle(start, 5, circlePaint..color = color);
          canvas.drawCircle(end, 5, circlePaint..color = color);
        }
      }
    }

    // Draw the rectangle that contains all points
    if (minX < maxX && minY < maxY) {
      paint.color = mainColor;
      ; // Change color if needed
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;

      // Draw the rectangle
      canvas.drawRect(
        Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY)),
        paint,
      );
    }

    if (confidence == 0) return;

    // Draw text above the rectangle
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$prediction (${(confidence * 100).toStringAsFixed(0)}%)',
        style: const TextStyle(
            color: mainColor, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate the center point and draw text above the rectangle
    double rectCenterX = (minX + maxX) / 2;
    double textY = minY - 50; // Offset to draw text above the rectangle
    textPainter.paint(
      canvas,
      Offset(rectCenterX - textPainter.width / 2, textY),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
