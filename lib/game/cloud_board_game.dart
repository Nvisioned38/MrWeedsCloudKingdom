import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../domain/match3.dart';

class CloudBoardGame extends FlameGame with TapCallbacks {
  CloudBoardGame({required this.session, required this.onTurn});
  final LevelSession session;
  final void Function(TurnResult result) onTurn;
  Cell? _selected;
  bool _resolving = false;
  double _feedbackLeft = 0;
  Set<Cell> _feedbackCells = {};
  int _cascadeLabel = 0;
  double _cascadeLeft = 0;
  Cell? _swapA;
  Cell? _swapB;
  Piece? _swapPieceA;
  Piece? _swapPieceB;

  static const colors = [
    Color(0xff78cbe9),
    Color(0xff5ca77a),
    Color(0xffffc857),
    Color(0xffb79adf),
    Color(0xfff28a70)
  ];

  @override
  Color backgroundColor() => const Color(0xff173d55);

  @override
  void update(double dt) {
    super.update(dt);
    if (_resolving) {
      _feedbackLeft -= dt;
      if (_feedbackLeft <= 0) {
        _resolving = false;
        _feedbackCells = {};
        _swapA = null;
        _swapB = null;
        _swapPieceA = null;
        _swapPieceB = null;
      }
    }
    if (_cascadeLeft > 0) _cascadeLeft -= dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final cellSize = size.x / session.board.cols;
    final tileSize = cellSize * .88;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var row = 0; row < session.board.rows; row++) {
      for (var col = 0; col < session.board.cols; col++) {
        final cell = Cell(row, col);
        final center = Offset((col + .5) * cellSize, (row + .5) * cellSize);
        paint.color = const Color(0xff244f67);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: center, width: tileSize, height: tileSize),
                const Radius.circular(9)),
            paint);
        final blocker = session.board.blockerAt(row, col);
        if (blocker != null) {
          _drawBlocker(canvas, center, tileSize, blocker);
        } else {
          final piece = session.board.at(row, col);
          if (piece != null &&
              !(_resolving && (_swapA == cell || _swapB == cell))) {
            _drawPiece(canvas, center, tileSize, piece);
          }
        }
        if (_selected == cell) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(
                      center: center,
                      width: cellSize * .97,
                      height: cellSize * .97),
                  const Radius.circular(10)),
              Paint()
                ..color = const Color(0xffffffff)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3);
        }
        if (_feedbackCells.contains(cell) && _feedbackLeft > 0) {
          final alpha = (_feedbackLeft / .28).clamp(0.0, 1.0).toDouble();
          canvas.drawCircle(
              center,
              tileSize * (.25 + .18 * (1 - alpha)),
              Paint()
                ..color = const Color(0x99fff2ad).withValues(alpha: alpha));
        }
      }
    }
    if (_resolving && _swapA != null && _swapB != null) {
      final progress = (1 - _feedbackLeft / .28).clamp(0.0, 1.0).toDouble();
      final a =
          Offset((_swapA!.col + .5) * cellSize, (_swapA!.row + .5) * cellSize);
      final b =
          Offset((_swapB!.col + .5) * cellSize, (_swapB!.row + .5) * cellSize);
      if (_swapPieceA != null) {
        _drawPiece(
            canvas, Offset.lerp(a, b, progress)!, tileSize, _swapPieceA!);
      }
      if (_swapPieceB != null) {
        _drawPiece(
            canvas, Offset.lerp(b, a, progress)!, tileSize, _swapPieceB!);
      }
    }
    if (_cascadeLeft > 0 && _cascadeLabel > 1) {
      _drawLabel(canvas, 'CASCADE ×$_cascadeLabel', Offset(size.x / 2, 18), 16,
          const Color(0xffffd36e),
          bold: true);
    }
  }

  void _drawPiece(Canvas canvas, Offset center, double size, Piece piece) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors[piece.family.index];
    final rect =
        Rect.fromCenter(center: center, width: size * .68, height: size * .68);
    switch (piece.family) {
      case TileFamily.cloud:
        canvas.drawCircle(center, size * .3, paint);
        canvas.drawCircle(
            center.translate(-size * .18, size * .03), size * .2, paint);
        canvas.drawCircle(
            center.translate(size * .18, size * .03), size * .2, paint);
        break;
      case TileFamily.leaf:
        canvas.drawOval(rect, paint);
        canvas.drawLine(
            center.translate(-size * .14, size * .2),
            center.translate(size * .14, -size * .2),
            Paint()
              ..color = const Color(0xfff4fff7)
              ..strokeWidth = 1.5);
        break;
      case TileFamily.sun:
        canvas.drawCircle(center, size * .24, paint);
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          canvas.drawLine(
              center.translate(
                  size * .29 * math.cos(angle), size * .29 * math.sin(angle)),
              center.translate(
                  size * .42 * math.cos(angle), size * .42 * math.sin(angle)),
              paint..strokeWidth = 3);
        }
        break;
      case TileFamily.moon:
        canvas.drawCircle(center, size * .3, paint);
        canvas.drawCircle(center.translate(size * .13, -size * .12), size * .26,
            Paint()..color = const Color(0xff244f67));
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
    if (piece.special != null) {
      final badge = switch (piece.special!) {
        SpecialKind.rocket => 'R',
        SpecialKind.prism => 'P',
        SpecialKind.cloudBomb => 'B'
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
  }

  void _drawBlocker(
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

  @override
  void onTapDown(TapDownEvent event) {
    if (_resolving || session.outcome != LevelOutcome.playing) return;
    final cellSize = size.x / session.board.cols;
    final col = (event.localPosition.x / cellSize).floor();
    final row = (event.localPosition.y / cellSize).floor();
    if (row < 0 ||
        row >= session.board.rows ||
        col < 0 ||
        col >= session.board.cols ||
        session.board.blockerAt(row, col) != null) {
      return;
    }
    final tapped = Cell(row, col);
    if (_selected == null) {
      _selected = tapped;
      return;
    }
    if (_selected == tapped) {
      _selected = null;
      return;
    }
    final from = _selected!;
    final pieceA = session.board.at(from.row, from.col);
    final pieceB = session.board.at(tapped.row, tapped.col);
    final result = session.swap(from, tapped);
    _selected = null;
    if (result.accepted) {
      _resolving = true;
      _feedbackLeft = .28;
      _feedbackCells = result.changedCells;
      _swapA = from;
      _swapB = tapped;
      _swapPieceA = pieceA;
      _swapPieceB = pieceB;
      _cascadeLabel = result.cascadeCount;
      _cascadeLeft = .8;
      onTurn(result);
    } else {
      _selected = tapped;
    }
  }
}
