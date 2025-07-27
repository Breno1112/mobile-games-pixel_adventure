import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/enums/player_state.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/settings/game_settings.dart';
import 'package:pixel_adventure/terrain/block_component.dart';

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

  Vector2 velocity = Vector2.zero();
  final gravity = 800;
  final double maxFallSpeed = 150;

  bool canFall = true;

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


  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is BlockComponent) {

      final playerBottom = position.y + size.y;
      final intersectionY = intersectionPoints.first.y;

      if (intersectionY >= playerBottom - 5) {
        // landed on top of block

        velocity.y = 0;

        // Align player on top of block (optional, helps avoid jittering)
        position.y = other.position.y - size.y;
        canFall = false;
        
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _applyGravity(dt);
    _applyMovement(dt);
  }

  void _applyGravity(double dt) {
    if (!canFall) return;

    velocity.y += gravity * dt;

    if (velocity.y > maxFallSpeed) {
      velocity.y = maxFallSpeed;
    }
  }

  void _applyMovement(double dt) {
    position += velocity * dt;
  }
}