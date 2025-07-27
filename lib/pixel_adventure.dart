import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/worlds/world_factory.dart';

class PixelAdventureGame extends FlameGame {

  PixelAdventureGame();

  @override
  FutureOr<void> onLoad() async {
    world = WorldFactory().getWorld();
    camera = CameraComponent(
      world: world
    );
    camera.viewfinder.anchor = Anchor(0.1, 0.8);
    await add(camera);
    await add(world);
    return super.onLoad();
  }
}