import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/entities/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/terrain/block_component.dart';

class DefaultWorld extends World with HasGameReference<PixelAdventureGame> {

  final String _levelFile;

  late TiledComponent _map;

  DefaultWorld(this._levelFile);

  @override
  Future<void> onLoad() async {
    await _loadWorld();
    await _spawnObjects();
  }

  Future<void> _loadWorld() async {
    _map = await TiledComponent.load(_levelFile, Vector2.all(16));
    add(_map);
  }

  Future<void> _spawnObjects() async {
    late Player player;
    _map.tileMap.getLayer<ObjectGroup>('Entities')?.objects.forEach((obj) {
      switch(obj.class_) {
        case 'Player':
          player = Player(position: obj.position);
          add(player);
          break;
        case 'Block':
          add(BlockComponent(position: obj.position));
        default:
          break;
      }
    });
    game.camera.follow(player);
    
  }
}