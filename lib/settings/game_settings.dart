import 'package:pixel_adventure/settings/player_settings/player_appearence.dart';
import 'package:pixel_adventure/settings/player_settings/player_settings.dart';

class GameSettings {

  late PlayerSettings _playerSettings;

  PlayerSettings get playerSettings => _playerSettings;

  GameSettings._() {
    // TODO(load this config dynamically)
    _playerSettings = PlayerSettings(playerAppearence: PlayerAppearence(playerSpriteName: 'mask_dude', playerName: 'Breno1112'));
  }

  static final GameSettings _instance = GameSettings._();

  factory GameSettings() {
    return _instance;
  }  

}