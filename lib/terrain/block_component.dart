import 'package:flame/components.dart';

class BlockComponent extends PositionComponent {

  BlockComponent({super.position}) :
    super(size: Vector2.all(200), anchor: Anchor.center);
}