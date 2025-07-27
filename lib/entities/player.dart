import 'package:flame/components.dart';
// ignore: unused_import
import 'package:flame/geometry.dart';
import 'package:pixel_adventure/enums/player_state.dart';
import 'package:pixel_adventure/pixel_adventure.dart';


class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameReference<PixelAdventureGame> {
  Player({super.position}) :
    super(size: Vector2.all(32), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {

    animations = <PlayerState, SpriteAnimation>{
      PlayerState.Idle: await createAnimation('main_characters/mask_dude/Idle (32x32).png', 11, 0.1, Vector2(32, 32)),
    };
    current = PlayerState.Idle;
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