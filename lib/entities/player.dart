import 'package:flame/components.dart';
// ignore: unused_import
import 'package:flame/geometry.dart';


class Player extends SpriteGroupComponent {
  Player({super.position}) :
    super(size: Vector2.all(32), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    sprites = {
      'Idle': await Sprite.load('main_characters/mask_dude/Idle (32x32).png'),
      // 'Run': await Sprite.load('main_characters/mask_dude/Run (32x32).png'),
      // 'Jump':await  Sprite.load('main_characters/mask_dude/Jump (32x32).png'),
      // 'Fall':await  Sprite.load('main_characters/mask_dude/Fall (32x32).png'),
      // 'Slide': await Sprite.load('main_characters/mask_dude/Slide (32x32).png'),
    };
    current = 'Idle';
  }
}