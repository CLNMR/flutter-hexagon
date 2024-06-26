library hexagon_ui;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

import 'hexagon_clipper.dart';
import 'hexagon_painter.dart';
import 'hexagon_path_builder.dart';

class HexagonWidget extends StatelessWidget {
  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [cornerRadius] - Radius of hexagon corners. Values <= 0 have no effect.
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  ///
  /// [type] - A type of hexagon has to be either [HexagonType.FLAT] or [HexagonType.POINTY]
  /// TODO: Add explanation of new parameters
  const HexagonWidget({
    Key? key,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.child,
    this.padding = 0.0,
    this.cornerRadius = 0.0,
    this.elevation = 0,
    this.inBounds = true,
    required this.type,
    this.onTap,
  })  : assert(width != null || height != null),
        assert(elevation >= 0),
        super(key: key);

  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [cornerRadius] - Border radius of hexagon corners. Values <= 0 have no effect.
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  HexagonWidget.flat({
    Key? key,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.child,
    this.padding = 0.0,
    this.elevation = 0,
    this.cornerRadius = 0.0,
    this.inBounds = true,
    this.onTap,
  })  : assert(width != null || height != null),
        assert(elevation >= 0),
        this.type = HexagonType.FLAT,
        super(key: key);

  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [cornerRadius] - Border radius of hexagon corners. Values <= 0 have no effect.
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  HexagonWidget.pointy({
    Key? key,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.child,
    this.padding = 0.0,
    this.elevation = 0,
    this.cornerRadius = 0.0,
    this.inBounds = true,
    this.onTap,
  })  : assert(width != null || height != null),
        assert(elevation >= 0),
        this.type = HexagonType.POINTY,
        super(key: key);

  final HexagonType type;
  final double? width;
  final double? height;
  final double elevation;
  final bool inBounds;
  final Widget? child;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final double padding;
  final double cornerRadius;
  final VoidCallback? onTap;

  Size _innerSize() {
    var flatFactor = type.flatFactor(inBounds);
    var pointyFactor = type.pointyFactor(inBounds);

    if (height != null && width != null) return Size(width!, height!);
    if (height != null)
      return Size((height! * type.ratio) * flatFactor / pointyFactor, height!);
    if (width != null)
      return Size(width!, (width! / type.ratio) / flatFactor * pointyFactor);
    return Size.zero; //dead path
  }

  Size _contentSize() {
    var flatFactor = type.flatFactor(inBounds);
    var pointyFactor = type.pointyFactor(inBounds);

    if (height != null && width != null) return Size(width!, height!);
    if (height != null)
      return Size(
          (height! * type.ratio) / pointyFactor, height! / pointyFactor);
    if (width != null)
      return Size(width! / flatFactor, (width! / type.ratio) / flatFactor);
    return Size.zero; //dead path
  }

  @override
  Widget build(BuildContext context) {
    var innerSize = _innerSize();
    var contentSize = _contentSize();

    HexagonPathBuilder pathBuilder = HexagonPathBuilder(type,
        inBounds: inBounds, borderRadius: cornerRadius);

    return GestureDetector(
      onTap: onTap,
      child: Align(
        child: Container(
          padding: EdgeInsets.all(padding),
          width: innerSize.width,
          height: innerSize.height,
          child: CustomPaint(
            painter: HexagonPainter(
              pathBuilder,
              color: color,
              borderColor: borderColor,
              borderWidth: borderWidth,
              elevation: elevation,
            ),
            child: ClipPath(
              clipper: HexagonClipper(pathBuilder),
              child: OverflowBox(
                alignment: Alignment.center,
                maxHeight: contentSize.height,
                maxWidth: contentSize.width,
                child: Align(
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HexagonWidgetBuilder {
  final double? elevation;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final double? padding;
  final double? cornerRadius;
  final bool? scale;
  final Widget? child;
  final VoidCallback? onTap;

  HexagonWidgetBuilder({
    this.elevation,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.cornerRadius,
    this.scale,
    this.child,
    this.onTap,
  });

  HexagonWidgetBuilder.transparent({
    this.padding,
    this.cornerRadius,
    this.child,
    this.scale,
    this.onTap,
  })  : this.elevation = 0,
        this.color = Colors.transparent,
        this.borderColor = Colors.transparent,
        this.borderWidth = 0;

  Widget build({
    Key? key,
    required HexagonType type,
    required inBounds,
    double? width,
    double? height,
    Widget? child,
    bool replaceChild = false,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = min(constraints.maxWidth, constraints.maxHeight);
      final factor = scale == true ? (width ?? size) / 60 : 1.0;
      return HexagonWidget(
        key: key,
        type: type,
        inBounds: inBounds,
        width: width,
        height: height,
        child: replaceChild ? child : this.child,
        color: color,
        borderColor: borderColor,
        borderWidth: factor * (borderWidth ?? 6.0),
        padding: factor * (padding ?? 0.0),
        cornerRadius: factor * (cornerRadius ?? 0.0),
        elevation: elevation ?? 0,
        onTap: onTap,
      );
    });
  }
}
