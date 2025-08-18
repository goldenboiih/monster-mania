import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flamegame/audio_manager.dart';
import 'package:flamegame/games/base_game.dart';

class MusicToggle extends SpriteComponent with TapCallbacks, HasGameReference<BaseGame> {
  late bool isMusicOn;
  late Sprite musicOnSprite;
  late Sprite musicOffSprite;


  MusicToggle() : super(
    size: Vector2(64, 64),
    priority: 10,
  );


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(game.size.x - size.x - 12, 12);
    musicOnSprite = await Sprite.load('ui/music_on.png');
    musicOffSprite = await Sprite.load('ui/music_off.png');

    sprite = AudioManager.isMusicOn ? musicOnSprite : musicOffSprite;
  }


  @override
  void onTapDown(TapDownEvent event) {
    AudioManager.toggleMusic().then((_) {
      sprite = AudioManager.isMusicOn ? musicOnSprite : musicOffSprite;
    });
  }
}
