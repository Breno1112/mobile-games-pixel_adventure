import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/entities/player/player_factory.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/terrain/block_component.dart';

class DefaultWorld extends World with HasGameReference<PixelAdventureGame> {

  final String _levelFile;

  late TiledComponent _map;

  DefaultWorld(this._levelFile);

  Player? _player;

  @override
  Future<void> onLoad() async {
    await _loadWorld();
    await _spawnObjects();
    await _postSetUpCamera();
  }

  Future<void> _loadWorld() async {
    _map = await TiledComponent.load(_levelFile, Vector2.all(16));
    add(_map);
  }

  Future<void> _spawnObjects() async {
    _map.tileMap.getLayer<ObjectGroup>('Entities')?.objects.forEach((obj) {
      switch(obj.class_) {
        case 'Player':
          _player = PlayerFactory().newPlayerOnPosition(obj.position);
          add(_player!);
          break;
        default:
          break;
      }
    });
    _map.tileMap.getLayer<ObjectGroup>('TerrainObjects')?.objects.forEach((obj) {
      switch(obj.class_) {
        case 'Block':
          add(BlockComponent(position: obj.position, size: obj.size));
          break;
        default:
          break;
      }
    });
  }
  
  Future<void> _postSetUpCamera() async {
    if (_player != null) {
      // game.camera.viewfinder.anchor = _player!.anchor;
      game.camera.follow(_player!);
    }
  }
}