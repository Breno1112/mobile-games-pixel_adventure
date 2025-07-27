import 'package:flame/components.dart';
import 'package:pixel_adventure/enums/player_state.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/settings/game_settings.dart';

class PlayerFactory {

  PlayerFactory._();

  static final PlayerFactory _instance = PlayerFactory._();

  Player? _currentPlayer;

  factory PlayerFactory() {
    return _instance;
  }

  Player getCurrentPlayer() {
    _currentPlayer ??= constructNewPlayer();
    return _currentPlayer!;
  }

  Player constructNewPlayer() {
    _currentPlayer = Player(spriteBaseName: GameSettings().playerSettings.playerAppearence.playerSpriteName);
    return _currentPlayer!;
  }

  Player newPlayerOnPosition(Vector2 position) {
    _currentPlayer = Player(
      spriteBaseName: GameSettings().playerSettings.playerAppearence.playerSpriteName,
      position: position
      );
    return _currentPlayer!;

  }

}

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameReference<PixelAdventureGame> {

  final String spriteBaseName;

  Player({super.position, required this.spriteBaseName}) :
    super(size: Vector2.all(32), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {

    animations = <PlayerState, SpriteAnimation>{
      PlayerState.doubleJump: await createAnimation('main_characters/$spriteBaseName/Double Jump (32x32).png', 11, 0.1, Vector2(32, 32)),
      PlayerState.fall: await createAnimation('main_characters/$spriteBaseName/Fall (32x32).png', 11, 0.1, Vector2(32, 32)),
      PlayerState.hit: await createAnimation('main_characters/$spriteBaseName/Hit (32x32).png', 11, 0.1, Vector2(32, 32)),
      PlayerState.idle: await createAnimation('main_characters/$spriteBaseName/Idle (32x32).png', 11, 0.1, Vector2(32, 32)),
      PlayerState.jump: await createAnimation('main_characters/$spriteBaseName/Jump (32x32).png', 11, 0.1, Vector2(32, 32)),
      PlayerState.run: await createAnimation('main_characters/$spriteBaseName/Run (32x32).png', 11, 0.1, Vector2(32, 32)),
      PlayerState.wallJump: await createAnimation('main_characters/$spriteBaseName/Wall Jump (32x32).png', 11, 0.1, Vector2(32, 32)),
    };
    current = PlayerState.idle;
  }

  Future<SpriteAnimation> createAnimation(String path, int count, double stepTime, Vector2 size) async {
    final image = await game.images.load(path);
    SpriteAnimation animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: count,          // number of frames
        stepTime: stepTime,       // duration per frame (in seconds)
        textureSize: size, // size of each frame
      ),
    );
    return animation;
  }
}