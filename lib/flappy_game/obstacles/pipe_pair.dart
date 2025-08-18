import 'dart:math';
import 'package:flame/components.dart';
import 'package:flamegame/flappy_game/flappy_game.dart';
import 'package:flamegame/flappy_game/obstacles/pipe.dart';
import 'package:flamegame/flappy_game/obstacles/score_zone.dart';

class PipePair extends PositionComponent with HasGameReference<FlappyGame> {
  PipePair({
    required super.position,      // center of the gap at spawn
    required this.gap,
    required this.pipeWidth,
    double? oscillationAmplitude, // pixels; if null we randomize
    double? oscillationSpeed,     // Hz; if null we randomize
  })  : _requestedAmp = oscillationAmplitude,
        _requestedSpeed = oscillationSpeed,
        super(priority: -1);

  final double gap;
  final double pipeWidth;

  final double? _requestedAmp;
  final double? _requestedSpeed;

  // Oscillation state
  late final double _baseY;
  late final double _phase;
  late final double _freq;   // Hz
  late double _amp;          // pixels
  double _t = 0;

  // Keep the gap from touching screen edges
  final double _edgeMargin = 80;
  // Ensure some visible movement
  final double _minAmp = 8;  // <- guarantees movement

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Build around local (0,0)
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
    final scoreZone = ScoreZone(size: Vector2(10, gap))
      ..position = Vector2.zero();

    addAll([topPipe, bottomPipe, scoreZone]);

    // --- Oscillation config ---
    _baseY = position.y;
    final rnd = Random();
    _phase = rnd.nextDouble() * pi * 2;
    _freq = _requestedSpeed ?? (0.35 + rnd.nextDouble() * 0.25); // 0.35–0.60 Hz

    final requested = _requestedAmp ?? (40 + rnd.nextDouble() * 35); // 40–75 px

    // Clamp amplitude so center±amp keeps the hole within safe band
    final minCenter = gap / 2 + _edgeMargin;
    final maxCenter = game.size.y - gap / 2 - _edgeMargin;
    final allowedTop = max(0, _baseY - minCenter);
    final allowedBottom = max(0, maxCenter - _baseY);
    final allowed = min(allowedTop, allowedBottom).toDouble();

    // Guarantee at least _minAmp so it always moves
    _amp = max(_minAmp, min(requested, allowed));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Scroll left with world speed
    x -= game.speed * dt;

    // Vertical oscillation
    _t += dt;
    final dy = sin((_t * _freq * 2 * pi) + _phase) * _amp;
    y = _baseY + dy;

    // Remove when off-screen (uses pipeWidth as approximate width)
    if (x + pipeWidth < 0) {
      removeFromParent();
    }
  }
}
