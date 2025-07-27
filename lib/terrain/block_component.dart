import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class BlockComponent extends PositionComponent {

  BlockComponent({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(position: position, size: size));
    debugMode = true;
  }
}