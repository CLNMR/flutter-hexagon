import 'dart:math';
import 'dart:ui';

extension OffsetRotate on Offset {
  /// Rotates the offset by the given angle in radians.
  Offset rotate(double angle) {
    final cosAngle = cos(angle);
    final sinAngle = sin(angle);
    return Offset(dx * cosAngle - dy * sinAngle, dx * sinAngle + dy * cosAngle);
  }
}
