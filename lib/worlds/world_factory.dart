import 'package:flame/components.dart';
import 'package:pixel_adventure/navigation/level_navigation_singleton.dart';
import 'package:pixel_adventure/worlds/concrete/default_world.dart';

class WorldFactory {

  WorldFactory._();

  static final WorldFactory _instance = WorldFactory._();

  final LevelNavigation _levelNavigation = LevelNavigation();

  factory WorldFactory() {
    return _instance;
  }

  World getWorld() {
    return DefaultWorld(_levelNavigation.getLevelName());
  }
}