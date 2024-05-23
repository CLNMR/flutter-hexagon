import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexagon_ui/src/grid/hexagon_grid.dart';
import 'package:hexagon_ui/src/offset_extension.dart';

class LinePainter extends CustomPainter {
  final List<HexagonLine> lines;

  LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: Expose those constants in the package API
    final arrowSize = 10;
    final arrowAngle = pi / 6;
    final lineTrim = 0.8;

    final weirdConstantSoThat1MeansHalfOfTheHexagon = 0.57;
    final realTrim = lineTrim * weirdConstantSoThat1MeansHalfOfTheHexagon;

    final grid = globalGridKey.currentContext!.findRenderObject() as RenderBox;
    for (final line in lines) {
      final startHex = globalCoordinateKeys[line.start]!
          .currentContext!
          .findRenderObject() as RenderBox;
      var startOffset = grid.globalToLocal(
          startHex.localToGlobal(startHex.size.center(Offset.zero)));
      final targetHex = globalCoordinateKeys[line.end]!
          .currentContext!
          .findRenderObject() as RenderBox;
      var targetOffset = grid.globalToLocal(
          targetHex.localToGlobal(targetHex.size.center(Offset.zero)));
      final angle = atan2(
          targetOffset.dy - startOffset.dy, targetOffset.dx - startOffset.dx);
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
                Offset(-arrowSize * cos(angle - arrowAngle),
                    -arrowSize * sin(angle - arrowAngle)),
            paint);
        canvas.drawLine(
            targetOffset,
            targetOffset +
                Offset(-arrowSize * cos(angle + arrowAngle),
                    -arrowSize * sin(angle + arrowAngle)),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
