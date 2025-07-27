import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/worlds/world_factory.dart';

class PixelAdventureGame extends FlameGame {

  PixelAdventureGame() {
    world = WorldFactory().getWorld();
    camera = CameraComponent.withFixedResolution(width: 240, height: 160);
  }

  @override
  FutureOr<void> onLoad() async {
    await add(world);
    return super.onLoad();
  }
}