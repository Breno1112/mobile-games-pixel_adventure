import 'package:flame/collisions.dart';
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

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameReference<PixelAdventureGame>, CollisionCallbacks {

  final String spriteBaseName;

  Player({super.position, required this.spriteBaseName}) :
    super(size: Vector2.all(32), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setUpAnimations();
    await _setUpHitbox();
    current = PlayerState.idle;
  }

  Future<void> _setUpAnimations() async {
    animations = <PlayerState, SpriteAnimation>{
      PlayerState.doubleJump: await _createAnimation('main_characters/$spriteBaseName/Double Jump (32x32).png', 6, 0.1, Vector2(32, 32), loop: false),
      PlayerState.fall: await _createAnimation('main_characters/$spriteBaseName/Fall (32x32).png', 1, 0.1, Vector2(32, 32), loop: false),
      PlayerState.hit: await _createAnimation('main_characters/$spriteBaseName/Hit (32x32).png', 7, 0.1, Vector2(32, 32), loop: false),
      PlayerState.idle: await _createAnimation('main_characters/$spriteBaseName/Idle (32x32).png', 11, 0.1, Vector2(32, 32)),
      PlayerState.jump: await _createAnimation('main_characters/$spriteBaseName/Jump (32x32).png', 1, 0.1, Vector2(32, 32), loop: false),
      PlayerState.run: await _createAnimation('main_characters/$spriteBaseName/Run (32x32).png', 12, 0.05, Vector2(32, 32)),
      PlayerState.wallJump: await _createAnimation('main_characters/$spriteBaseName/Wall Jump (32x32).png', 5, 0.1, Vector2(32, 32), loop: false),
    };
  }

  Future<SpriteAnimation> _createAnimation(String path, int count, double stepTime, Vector2 size, {bool loop = true}) async {
    final image = await game.images.load(path);
    SpriteAnimation animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: count,          // number of frames
        stepTime: stepTime,       // duration per frame (in seconds)
        textureSize: size, // size of each frame
        loop: loop
      ),
    );
    return animation;
  }
  
  Future<void> _setUpHitbox() async {
    add(RectangleHitbox(size: Vector2.all(32)));
    debugMode = true;
  }

  @override void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    print("Player collided with ${other.runtimeType}. Player coordinates are ${position.x.toInt()}; ${position.y.toInt()}");
    print("Coordinates of the intersection points are");
    intersectionPoints.forEach((item) {
      print("${item.x}; ${item.y}");
    });
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    print("Player finished colliding with ${other.runtimeType}. Player coordinates are ${position.x.toInt()}; ${position.y.toInt()}");
    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 10 * dt;
    // print("Player updated! New position is ${position.x}; ${position.y}");
  }
}