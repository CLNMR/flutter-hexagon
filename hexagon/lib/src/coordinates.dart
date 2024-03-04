import 'dart:math';

import 'package:hexagon/src/hexagon_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coordinates.g.dart';

///Unified representation of cube and axial coordinates systems.
@JsonSerializable()
class Coordinates {
  Coordinates(int q, int r) : this.axial(q, r);

  /// Cube constructor
  const Coordinates.cube(this.x, this.y, this.z);

  /// Axial constructor
  Coordinates.axial(int q, int r)
      : this.x = q,
        this.y = (-q - r).toInt(),
        this.z = r;

  final int x, y, z;

  int get q => x;

  int get r => z;

  /// Get a short axial representation of the coordinates.
  String get axialRep =>
      '(${_convertToPrettyNum(q)}, ${_convertToPrettyNum(r)})';

  /// Convert the given integer to a pretty (i.e. no -0 or 0.0) string.
  String _convertToPrettyNum(int num) => (num == 0) ? '0' : num.toString();

  ///Distance measured in steps between tiles. A single step is only going over edge of neighboring tiles.
  int distance(Coordinates other) {
    return max(
        (x - other.x).abs(), max((y - other.y).abs(), (z - other.z).abs()));
  }

  Coordinates operator +(Coordinates other) {
    return Coordinates.cube(x + other.x, y + other.y, z + other.z);
  }

  Coordinates operator -(Coordinates other) {
    return Coordinates.cube(x - other.x, y - other.y, z - other.z);
  }

  Coordinates rotateClockwise(int steps) {
    if (steps == 0) return this;
    if (steps < 0) return rotateClockwise(steps % 6);
    return Coordinates.cube(-y, -z, -x).rotateClockwise(steps - 1);
  }

  @override
  bool operator ==(Object other) =>
      other is Coordinates && other.x == x && other.y == y && other.z == z;

  /// The hash code is unique up to a grid size of 2^26 - 1 rings.
  @override
  int get hashCode =>
      (pow(2, 25).toInt() + q) + (pow(2, 25).toInt() + r) * pow(2, 26).toInt();

  ///Constant value of space center
  static const Coordinates zero = Coordinates.cube(0, 0, 0);

  @override
  String toString() => 'Coordinates[cube: ($x, $y, $z), axial: ($q, $r)]';

  static List<Coordinates> fromList(List<(int, int)> list) =>
      list.map((e) => Coordinates.axial(e.$1, e.$2)).toList();

  static List<Coordinates> generateRings(int radius) {
    List<Coordinates> cells = [];
    for (int q = -radius; q <= radius; q++) {
      int r1 = max(-radius, -q - radius);
      int r2 = min(radius, -q + radius);
      for (int r = r1; r <= r2; r++) {
        cells.add(Coordinates(q, r));
      }
    }
    return cells;
  }

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);

  List<Coordinates> getNeighbors({HexagonType type = HexagonType.FLAT}) {
    if (type == HexagonType.FLAT) {
      return HexDirectionsFlat.values.map((e) => this + e.coord).toList();
    } else {
      return HexDirectionsPointy.values.map((e) => this + e.coord).toList();
    }
  }
}

enum HexDirectionsPointy {
  pointyRight(Coordinates.cube(1, 1, 0)),
  pointyLeft(Coordinates.cube(-1, 1, 0)),
  pointyTopRight(Coordinates.cube(1, 0, -1)),
  pointyTopLeft(Coordinates.cube(0, 1, -1)),
  pointyDownRight(Coordinates.cube(0, -1, 1)),
  pointyDownLeft(Coordinates.cube(-1, 0, 1));

  const HexDirectionsPointy(this.coord);
  final Coordinates coord;
}

enum HexDirectionsFlat {
  flatTop(Coordinates.cube(0, 1, -1)),
  flatDown(Coordinates.cube(0, -1, 1)),
  flatRightTop(Coordinates.cube(1, 0, -1)),
  flatRightDown(Coordinates.cube(1, -1, 0)),
  flatLeftTop(Coordinates.cube(-1, 1, 0)),
  flatLeftDown(Coordinates.cube(-1, 0, 1));

  const HexDirectionsFlat(this.coord);
  final Coordinates coord;
}
