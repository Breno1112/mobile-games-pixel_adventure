class LevelNavigation {

  LevelNavigation._();

  static final LevelNavigation _instance = LevelNavigation._();

  int _currentLevel = 1;

  factory LevelNavigation() {
    return _instance;
  }

  String getLevelName() {
    return 'levels/level_$_currentLevel.tmx';
  }

  void nextLevel() {
    _currentLevel ++;
  }

  void previousLevel() {
    _currentLevel --;
    if (_currentLevel < 1) {
      _currentLevel = 1;
    }
  }
}