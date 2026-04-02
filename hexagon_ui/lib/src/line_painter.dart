import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexagon_ui/src/grid/hexagon_grid.dart';
import 'package:hexagon_ui/src/offset_extension.dart';

class LinePainter extends CustomPainter {
  final List<HexagonLine> lines;

  /// Size of the arrowhead in logical pixels.
  final double arrowSize;

  /// Half-angle of the arrowhead in radians.
  final double arrowAngle;

  /// How far the line endpoint is trimmed towards the center of the target
  /// hexagon (0 = no trim, 1 = full radius).
  final double lineTrim;

  LinePainter(
    this.lines, {
    this.arrowSize = 10,
    this.arrowAngle = pi / 6,
    this.lineTrim = 0.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final weirdConstantSoThat1MeansHalfOfTheHexagon = 0.57;
    final realTrim = lineTrim * weirdConstantSoThat1MeansHalfOfTheHexagon;

    final grid = globalGridKey.currentContext!.findRenderObject() as RenderBox;
    for (final line in lines) {
      final startHex =
          globalCoordinateKeys[line.start]!.currentContext!.findRenderObject()
              as RenderBox;
      var startOffset = grid.globalToLocal(
        startHex.localToGlobal(startHex.size.center(Offset.zero)),
      );
      final targetHex =
          globalCoordinateKeys[line.end]!.currentContext!.findRenderObject()
              as RenderBox;
      var targetOffset = grid.globalToLocal(
        targetHex.localToGlobal(targetHex.size.center(Offset.zero)),
      );
      final angle = atan2(
        targetOffset.dy - startOffset.dy,
        targetOffset.dx - startOffset.dx,
      );
      final rotatedOffset = line.offset.rotate(angle);

      startOffset += rotatedOffset;
      targetOffset += rotatedOffset;

      targetOffset +=
          -Offset(cos(angle), sin(angle)) * realTrim * startHex.size.width;

      final paints = [
        if (line.borderColor != null)
          Paint()
            ..color = line.borderColor!
            ..strokeWidth = line.width + 2,
        Paint()
          ..color = line.color
          ..strokeWidth = line.width,
      ];

      for (final paint in paints) {
        canvas.drawLine(startOffset, targetOffset, paint);

        canvas.drawLine(
          targetOffset,
          targetOffset +
              Offset(
                -arrowSize * cos(angle - arrowAngle),
                -arrowSize * sin(angle - arrowAngle),
              ),
          paint,
        );
        canvas.drawLine(
          targetOffset,
          targetOffset +
              Offset(
                -arrowSize * cos(angle + arrowAngle),
                -arrowSize * sin(angle + arrowAngle),
              ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
