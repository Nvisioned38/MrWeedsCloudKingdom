import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../domain/match3.dart';
import 'board_sprite_renderer.dart';

class CloudBoardGame extends FlameGame with TapCallbacks {
  CloudBoardGame({
    required this.session,
    required this.onTurn,
    BoardSpriteRenderer? spriteRenderer,
    BoardEffectsHook? effectsHook,
    this.reducedMotion = false,
  })  : spriteRenderer =
            spriteRenderer ?? const CloudKingdomFallbackBoardRenderer(),
        effectsHook = effectsHook ?? const NoBoardEffectsHook();

  final BoardSpriteRenderer spriteRenderer;
  final BoardEffectsHook effectsHook;
  final bool reducedMotion;
  final LevelSession session;
  final void Function(TurnResult result) onTurn;
  Cell? _selected;
  bool _resolving = false;
  double _feedbackLeft = 0;
  double _feedbackDuration = .28;
  Set<Cell> _feedbackCells = {};
  int _cascadeLabel = 0;
  double _cascadeLeft = 0;
  Cell? _swapA;
  Cell? _swapB;
  Piece? _swapPieceA;
  Piece? _swapPieceB;

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
          spriteRenderer.drawBlocker(canvas, center, tileSize, blocker);
        } else {
          final piece = session.board.at(row, col);
          if (piece != null &&
              !(_resolving && (_swapA == cell || _swapB == cell))) {
            spriteRenderer.drawPiece(canvas, center, tileSize, piece);
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
      final progress =
          (1 - _feedbackLeft / _feedbackDuration).clamp(0.0, 1.0).toDouble();
      final a =
          Offset((_swapA!.col + .5) * cellSize, (_swapA!.row + .5) * cellSize);
      final b =
          Offset((_swapB!.col + .5) * cellSize, (_swapB!.row + .5) * cellSize);
      if (_swapPieceA != null) {
        spriteRenderer.drawPiece(
            canvas, Offset.lerp(a, b, progress)!, tileSize, _swapPieceA!);
      }
      if (_swapPieceB != null) {
        spriteRenderer.drawPiece(
            canvas, Offset.lerp(b, a, progress)!, tileSize, _swapPieceB!);
      }
    }
    if (!reducedMotion && _cascadeLeft > 0 && _cascadeLabel > 1) {
      _drawLabel(canvas, 'CASCADE ×$_cascadeLabel', Offset(size.x / 2, 18), 16,
          const Color(0xffffd36e),
          bold: true);
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
      _feedbackDuration = reducedMotion ? .04 : .28;
      _feedbackLeft = _feedbackDuration;
      _feedbackCells = result.changedCells;
      _swapA = from;
      _swapB = tapped;
      _swapPieceA = pieceA;
      _swapPieceB = pieceB;
      _cascadeLabel = result.cascadeCount;
      _cascadeLeft = reducedMotion ? 0 : .8;
      effectsHook.onAcceptedTurn(result);
      onTurn(result);
    } else {
      _selected = tapped;
    }
  }
}
