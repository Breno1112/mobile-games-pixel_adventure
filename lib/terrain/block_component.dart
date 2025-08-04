import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class BlockComponent extends PositionComponent {

  BlockComponent({super.position, super.size}): super(anchor: Anchor.topLeft);

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: size));
    debugMode = true;
  }
}