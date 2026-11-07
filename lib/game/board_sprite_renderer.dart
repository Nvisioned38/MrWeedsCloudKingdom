import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../domain/match3.dart';

/// Presentation boundary for replaceable Match-3 sprites.
///
/// The current renderer is an explicitly unfinished vector fallback. Approved
/// sprites can replace it without changing Match-3 state or save identifiers.
abstract interface class BoardSpriteRenderer {
  void drawPiece(Canvas canvas, Offset center, double size, Piece piece);

  void drawBlocker(
      Canvas canvas, Offset center, double size, BlockerState blocker);
}

/// Optional integration point for haptics, sound, or analytics owned by UI.
abstract interface class BoardEffectsHook {
  void onAcceptedTurn(TurnResult result);
}

class NoBoardEffectsHook implements BoardEffectsHook {
  const NoBoardEffectsHook();

  @override
  void onAcceptedTurn(TurnResult result) {}
}

class CloudKingdomFallbackBoardRenderer implements BoardSpriteRenderer {
  const CloudKingdomFallbackBoardRenderer();

  static const _colors = [
    Color(0xff78cbe9),
    Color(0xff5ca77a),
    Color(0xffffc857),
    Color(0xffb79adf),
    Color(0xfff28a70),
  ];

  @override
  void drawPiece(Canvas canvas, Offset center, double size, Piece piece) {
    if (piece.fogged) {
      final fog = Paint()..color = const Color(0xffacbfd0);
      canvas.drawCircle(center.translate(-size * .1, 0), size * .25, fog);
      canvas.drawCircle(
          center.translate(size * .1, size * .02), size * .27, fog);
      canvas.drawCircle(center.translate(0, size * .12), size * .23, fog);
      _drawLabel(canvas, '?', center, size * .4, const Color(0xff173d55),
          bold: true);
    } else {
      _drawIdentity(canvas, center, size, piece);
    }
    if (piece.stickySyrup) {
      final syrupRect = Rect.fromCenter(
          center: center.translate(0, size * .28),
          width: size * .58,
          height: size * .2);
      canvas.drawRRect(
          RRect.fromRectAndRadius(syrupRect, const Radius.circular(6)),
          Paint()..color = const Color(0xffd78f32));
      _drawLabel(canvas, 'STUCK', center.translate(0, size * .28), size * .12,
          const Color(0xff271b12),
          bold: true);
    }
  }

  void _drawIdentity(Canvas canvas, Offset center, double size, Piece piece) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = piece.family == TileFamily.leaf
          ? const Color(0xff58ad77)
          : _colors[piece.family.index];
    switch (piece.family) {
      case TileFamily.cloud:
        canvas.drawCircle(center, size * .3, paint);
        canvas.drawCircle(
            center.translate(-size * .18, size * .03), size * .2, paint);
        canvas.drawCircle(
            center.translate(size * .18, size * .03), size * .2, paint);
        break;
      case TileFamily.leaf:
        // Legacy save/domain identity maps to the approved green spiral bloom.
        // Do not expose the old leaf-shaped visual in gameplay.
        for (var i = 0; i < 6; i++) {
          final angle = -math.pi / 2 + i * 2 * math.pi / 6;
          canvas.drawCircle(
              center.translate(
                  size * .19 * math.cos(angle), size * .19 * math.sin(angle)),
              size * .135,
              paint);
        }
        canvas.drawCircle(
            center, size * .11, Paint()..color = const Color(0xffd8f2a1));
        final spiral = Path();
        for (var step = 0; step <= 36; step++) {
          final progress = step / 36;
          final radius = size * .085 * progress;
          final angle = -math.pi * 3 * progress;
          final point = center.translate(
            radius * math.cos(angle),
            radius * math.sin(angle),
          );
          if (step == 0) {
            spiral.moveTo(point.dx, point.dy);
          } else {
            spiral.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(
          spiral,
          Paint()
            ..color = const Color(0xff35704c)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size * .035
            ..strokeCap = StrokeCap.round,
        );
        break;
      case TileFamily.sun:
        final flame = Path()
          ..moveTo(center.dx, center.dy - size * .36)
          ..quadraticBezierTo(center.dx + size * .35, center.dy - size * .02,
              center.dx, center.dy + size * .33)
          ..quadraticBezierTo(center.dx - size * .35, center.dy - size * .02,
              center.dx, center.dy - size * .36)
          ..close();
        canvas.drawPath(flame, paint);
        break;
      case TileFamily.moon:
        final diamond = Path()
          ..moveTo(center.dx, center.dy - size * .36)
          ..lineTo(center.dx + size * .28, center.dy)
          ..lineTo(center.dx, center.dy + size * .36)
          ..lineTo(center.dx - size * .28, center.dy)
          ..close();
        canvas.drawPath(diamond, paint);
        break;
      case TileFamily.star:
        final path = Path();
        for (var i = 0; i < 10; i++) {
          final angle = -math.pi / 2 + i * math.pi / 5;
          final radius = i.isEven ? size * .36 : size * .16;
          final point = center.translate(
              radius * math.cos(angle), radius * math.sin(angle));
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
    if (piece.special != null) _drawSpecial(canvas, center, size, piece);
  }

  void _drawSpecial(Canvas canvas, Offset center, double size, Piece piece) {
    final badge = switch (piece.special!) {
      SpecialKind.rocket => 'R',
      SpecialKind.prism => 'P',
      SpecialKind.cloudBomb => 'B',
    };
    canvas.drawCircle(
        center, size * .19, Paint()..color = const Color(0xfff9f4dc));
    _drawLabel(canvas, badge, center, size * .22, const Color(0xff14354a),
        bold: true);
    if (piece.special == SpecialKind.rocket) {
      final direction = piece.direction == RocketDirection.vertical
          ? Offset(0, size * .31)
          : Offset(size * .31, 0);
      canvas.drawLine(
          center - direction,
          center + direction,
          Paint()
            ..color = const Color(0xfff9f4dc)
            ..strokeWidth = 2.5);
    }
  }

  @override
  void drawBlocker(
      Canvas canvas, Offset center, double size, BlockerState blocker) {
    final reinforced = blocker.kind == BlockerKind.reinforcedCrate;
    final fill = blocker.damaged
        ? const Color(0xff9f6957)
        : reinforced
            ? const Color(0xff8e6640)
            : const Color(0xffb57942);
    final rect =
        Rect.fromCenter(center: center, width: size * .68, height: size * .68);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()..color = fill);
    final stroke = Paint()
      ..color = const Color(0xfff2d3a2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect.deflate(size * .1), const Radius.circular(3)),
        stroke);
    if (reinforced) {
      canvas.drawLine(Offset(rect.left + 2, center.dy),
          Offset(rect.right - 2, center.dy), stroke);
    }
    _drawLabel(canvas, 'MW', center, size * .2, const Color(0xfffff2d3),
        bold: true);
    if (blocker.damaged) {
      final crack = Paint()
        ..color = const Color(0xff321f1a)
        ..strokeWidth = 2;
      canvas.drawLine(center.translate(-size * .06, -size * .2),
          center.translate(size * .02, -size * .03), crack);
      canvas.drawLine(center.translate(size * .02, -size * .03),
          center.translate(-size * .06, size * .04), crack);
      canvas.drawLine(center.translate(-size * .06, size * .04),
          center.translate(size * .08, size * .2), crack);
    }
  }

  void _drawLabel(
      Canvas canvas, String text, Offset center, double fontSize, Color color,
      {bool bold = false}) {
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(
        canvas, center.translate(-painter.width / 2, -painter.height / 2));
  }
}
