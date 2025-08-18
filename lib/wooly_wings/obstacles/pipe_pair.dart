import 'dart:math';
import 'package:flame/components.dart';

import 'package:flamegame/wooly_wings//wooly_wings_game.dart';
import 'package:flamegame/wooly_wings/obstacles/score_zone.dart';
import 'package:flamegame/wooly_wings/obstacles/pipe.dart';

class PipePair extends PositionComponent with HasGameReference<WoolyWings> {
  PipePair({
    required super.position,      // initial center (x, y)
    required this.gap,            // hole size
    required this.pipeWidth,
    double? oscillationAmplitude, // optional: pixels
    double? oscillationSpeed,     // optional: cycles per second
  })  : _requestedAmp = oscillationAmplitude,
        _requestedSpeed = oscillationSpeed,
        super(priority: -1);

  final double gap;
  final double pipeWidth;

  // Oscillation config (randomized if not provided)
  final double? _requestedAmp;
  final double? _requestedSpeed;

  // Internal oscillation state
  late final double _baseY;
  late final double _phase;          // random phase so not all pairs sync
  late final double _freq;           // Hz
  late double _amp;                  // pixels (clamped to screen)
  double _t = 0;                     // time accumulator

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Build pipes around the local center (0,0)
    final topPipe = Pipe(
      isFlipped: true,
      position: Vector2(0, -gap / 2),
      pipeWidth: pipeWidth,
    );
    final bottomPipe = Pipe(
      isFlipped: false,
      position: Vector2(0, gap / 2),
      pipeWidth: pipeWidth,
    );

    // Scoring zone in the middle of the gap
    final scoreZone = ScoreZone(size: Vector2(10, gap))..position = Vector2.zero();

    addAll([topPipe, bottomPipe, scoreZone]);

    // --- Oscillation setup ---
    _baseY = position.y;
    final rnd = Random();

    // Randomize phase so consecutive pairs aren't in lockstep
    _phase = rnd.nextDouble() * pi * 2;

    // Speed (Hz, i.e., cycles per second)
    _freq = _requestedSpeed ?? (0.25 + rnd.nextDouble() * 0.35); // ~0.25–0.6 Hz

    // Requested amplitude or randomized default
    final requestedAmp = _requestedAmp ?? (30 + rnd.nextDouble() * 40); // ~30–70 px

    // Clamp amplitude so the center never pushes pipes off-screen
    // Keep at least 40 px margin from edges for sprites
    final margin = 40.0;
    final topLimit = gap / 2 + margin;
    final bottomLimit = game.size.y - gap / 2 - margin;

    // Maximum allowed amplitude around the chosen baseY
    final allowedTop = _baseY - topLimit;
    final allowedBottom = bottomLimit - _baseY;
    _amp = max(0, min(requestedAmp, min(allowedTop, allowedBottom)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Horizontal scroll
    x -= game.speed * dt;

    // Vertical oscillation of the whole pair
    _t += dt;
    final dy = sin((_t * _freq * 2 * pi) + _phase) * _amp;
    y = _baseY + dy;

    // Cull when fully off-screen to the left
    if (x + pipeWidth < 0) {
      removeFromParent();
    }
  }
}
