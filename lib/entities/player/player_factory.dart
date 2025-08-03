// ignore_for_file: implementation_imports

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
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
    _currentPlayer = Player(
      spriteBaseName:
          GameSettings().playerSettings.playerAppearence.playerSpriteName,
    );
    return _currentPlayer!;
  }

  Player newPlayerOnPosition(Vector2 position) {
    _currentPlayer = Player(
      spriteBaseName:
          GameSettings().playerSettings.playerAppearence.playerSpriteName,
      position: position,
    );
    return _currentPlayer!;
  }
}

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        HasGameReference<PixelAdventureGame>,
        CollisionCallbacks,
        KeyboardHandler {
  final String spriteBaseName;


  Vector2 velocity = Vector2.zero();

  // handle horizontal movement
  final int horizontalMaxNormalMoveSpeed = 250;
  final int horizontalMaxRunningMoveSpeed = 500;
  final int horizontalNormalMoveSpeedAcceleration = 250;
  final int horizontalRunningMoveSpeedAcceleration = 500;
  final int horizontalDragMoveSpeed = 50000;
  final int maxFramesToStopHorizontalMovement = 10;
  int usedFramesToStopHorizontalMovement = 0;
  bool canRun = true;
  bool _running = false;


  // handle animation side
  bool isFacingRight = true;


  // handle gravity
  final gravity = 800;
  final double maxFallSpeed = 350;
  bool canFall = true;

  // handle keyboard
  Set<int> _keysPressed = {};
  Set<int> _horizontalKeysPressed = {};

  // handle jump

  final double jumpForce = 350;
  bool canJump = true;

  Player({super.position, required this.spriteBaseName})
    : super(size: Vector2.all(32), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _setUpAnimations();
    await _setUpHitbox();
    current = PlayerState.idle;
  }

  Future<void> _setUpAnimations() async {
    animations = <PlayerState, SpriteAnimation>{
      PlayerState.doubleJump: await _createAnimation(
        'main_characters/$spriteBaseName/Double Jump (32x32).png',
        6,
        0.1,
        Vector2(32, 32),
        loop: false,
      ),
      PlayerState.fall: await _createAnimation(
        'main_characters/$spriteBaseName/Fall (32x32).png',
        1,
        0.1,
        Vector2(32, 32),
        loop: false,
      ),
      PlayerState.hit: await _createAnimation(
        'main_characters/$spriteBaseName/Hit (32x32).png',
        7,
        0.1,
        Vector2(32, 32),
        loop: false,
      ),
      PlayerState.idle: await _createAnimation(
        'main_characters/$spriteBaseName/Idle (32x32).png',
        11,
        0.1,
        Vector2(32, 32),
      ),
      PlayerState.jump: await _createAnimation(
        'main_characters/$spriteBaseName/Jump (32x32).png',
        1,
        0.1,
        Vector2(32, 32),
        loop: false,
      ),
      PlayerState.run: await _createAnimation(
        'main_characters/$spriteBaseName/Run (32x32).png',
        12,
        0.03,
        Vector2(32, 32),
      ),
      PlayerState.wallJump: await _createAnimation(
        'main_characters/$spriteBaseName/Wall Jump (32x32).png',
        5,
        0.1,
        Vector2(32, 32),
        loop: false,
      ),
      PlayerState.walk: await _createAnimation(
        'main_characters/$spriteBaseName/Run (32x32).png',
        12,
        0.1,
        Vector2(32, 32),
      ),
    };
  }

  Future<SpriteAnimation> _createAnimation(
    String path,
    int count,
    double stepTime,
    Vector2 size, {
    bool loop = true,
  }) async {
    final image = await game.images.load(path);
    SpriteAnimation animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: count, // number of frames
        stepTime: stepTime, // duration per frame (in seconds)
        textureSize: size, // size of each frame
        loop: loop,
      ),
    );
    return animation;
  }

  Future<void> _setUpHitbox() async {
    add(RectangleHitbox(size: Vector2.all(32)));
    debugMode = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _applyGravity(dt);
    _checkKeyboardInput(dt);
    _applyMovement(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    switch (other.runtimeType) {
      case const (BlockComponent):
        _onCollidedWithBlock(intersectionPoints, other);
    }
  }

  void _onCollidedWithBlock(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    final playerBottom = position.y + size.y;
    final intersectionY = intersectionPoints.first.y;

    if (intersectionY >= playerBottom - 5) {
      // landed on top of block

      velocity.y = 0;

      // Align player on top of block (optional, helps avoid jittering)
      position.y = other.position.y - size.y;
      canFall = false;
      canJump = true;
    }
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
    _updatePlayerAnimation(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed = keysPressed.map((i) => i.keyId).toSet();
    _remapHorizontalKeysPressed(keysPressed);
    return super.onKeyEvent(event, keysPressed);
  }

  void _remapHorizontalKeysPressed(Set<LogicalKeyboardKey> keysPressed) {
    final Set<int> horizontalKeys = {
      LogicalKeyboardKey.arrowLeft.keyId,
      LogicalKeyboardKey.arrowRight.keyId,
      LogicalKeyboardKey.keyA.keyId,
      LogicalKeyboardKey.keyD.keyId,
      };
    _horizontalKeysPressed = keysPressed.map((i) => i.keyId).where((i) => horizontalKeys.contains(i)).toSet();
  }

  void _checkKeyboardInput(double dt) {
    if (_horizontalKeysPressed.isEmpty) {
      print("empty horizontal keys pressed");
      _stopHorizontalMovement(dt);
    }
    if (_keysPressed.contains(LogicalKeyboardKey.space.keyId)) {
      _jump(dt);
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight.keyId) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD.keyId)) {
      _moveHorizontally(1, _keysPressed.contains(LogicalKeyboardKey.shiftLeft.keyId), dt);
    } else if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft.keyId) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA.keyId)) {
      _moveHorizontally(
        -1,
        _keysPressed.contains(LogicalKeyboardKey.shiftLeft.keyId),
        dt
      );
    }

    print("velocity.x = ${velocity.x}");
  }

  void _moveHorizontally(int i, bool running, double dt) {
    _running = running;
    print("isFacingRight = ${isFacingRight}\ni = ${i}\nvelocity.x = ${velocity.x}");
    if (isFacingRight && i < 0 && velocity.x > 0) {
      _stopHorizontalMovement(dt);
      return;
    } else if (!isFacingRight && i > 0 && velocity.x < 0) {
      _stopHorizontalMovement(dt);
      return;
    }
    _conditionallyFlipSprite(i);
    if (canRun && running) {
      velocity.x += horizontalRunningMoveSpeedAcceleration * i.toDouble() * dt;
      if (velocity.x.abs() > horizontalMaxRunningMoveSpeed) {
        velocity.x = horizontalMaxRunningMoveSpeed * i.toDouble();
      }
      if (current != PlayerState.jump && current != PlayerState.fall) {
        // current = PlayerState.run;
      }
    } else {
      velocity.x += horizontalNormalMoveSpeedAcceleration * i.toDouble() * dt;
      if (velocity.x.abs() > horizontalMaxNormalMoveSpeed) {
        velocity.x = horizontalMaxNormalMoveSpeed * i.toDouble();
      }
      if (current != PlayerState.jump && current != PlayerState.fall) {
        // current = PlayerState.walk;
      }
    }
  }

  void _debugKeysPressed() {
    if (_keysPressed.isEmpty) {
      print("no keys are being pressed!");
    }
    for (int i in _keysPressed) {
      print("pressing key id = ${i}");
    }
  }
  
  void _stopHorizontalMovement(double dt) {
    int direction = 0;
    double dragSpeed = horizontalDragMoveSpeed.toDouble();
    if (velocity.x > 0) {
      direction = -1;
    } else if (velocity.x < 0) {
      direction = 1;
    } else {
      return;
    }
    if (velocity.x.abs() < (horizontalDragMoveSpeed * dt).abs()) {
      dragSpeed = velocity.x.abs() / dt / maxFramesToStopHorizontalMovement;
      usedFramesToStopHorizontalMovement ++;
    }

    if (usedFramesToStopHorizontalMovement >= maxFramesToStopHorizontalMovement) {
      velocity.x = 0;
      usedFramesToStopHorizontalMovement = 0;
      // current = PlayerState.idle;
    } else {
      velocity.x += dragSpeed * direction * dt;
    }
  }
  
  void _conditionallyFlipSprite(int i) {
    if (
      isFacingRight && i < 0 ||
        !isFacingRight && i > 0
      ) {
      flipHorizontallyAroundCenter();
      isFacingRight = !isFacingRight;
    }
    print("isFacingRight = ${isFacingRight}\ni = ${i}");
  }

  void _jump(dt) {
    if (!canJump) {
      return;
    }
    velocity.y -= jumpForce;
    canJump = false;
    canFall = true;
    // current = PlayerState.jump;
  }
  
  void _updatePlayerAnimation(double dt) {
    if (velocity.y < 0) {
      current = PlayerState.jump;
    } else if (velocity.y > 0) {
      current = PlayerState.fall;
    } else if (_running) {
      current = PlayerState.run;
    } else if (velocity.x.abs() > 0 && !_running) {
      current = PlayerState.walk;
    } else {
      current = PlayerState.idle;
    }
  }
}
