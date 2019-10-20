import 'package:flutter/material.dart';
import 'GameEntity.dart';
import '../Helper/util.dart';

class DraggableEntity extends StatefulWidget {
  final GameEntity gameEntity;
  final Function(GameEntity gameEntity) onDrop;
  final Function onLongPress; //TODO precise signature
  final double gravityField;
  final Widget child;

  DraggableEntity({
    @required this.gameEntity,
    @required this.onDrop,
    @required this.onLongPress,
    @required this.gravityField,
    @required this.child
  });

  @override
  _DraggableEntityState createState() => _DraggableEntityState();
}

class _DraggableEntityState extends State<DraggableEntity> {
  @override
  Widget build(BuildContext context) {
    return widget.gameEntity.positioned(
        gravity: widget.gravityField,
        child: GestureDetector(
          onPanStart: (details) {
            //print("Selected: ${widget.gameEntity.ID}");
          },
          onPanUpdate: (details) {
            //Need to update position of entity
            setState(() {
              var widthLimit = MediaQuery.of(context).size.width;
              var heightLimit = MediaQuery.of(context).size.height;

              var newPosition = widget.gameEntity.position +
                  Coordinates.fromOffset(details.delta);
              // Check we don't go out of screen
              if (!(newPosition.x - widget.gameEntity.entityRadius < 0 ||
                  newPosition.x + widget.gameEntity.entityRadius > widthLimit ||
                  newPosition.y - widget.gameEntity.entityRadius < 0 ||
                  newPosition.y + widget.gameEntity.entityRadius > heightLimit))
                widget.gameEntity.position = newPosition;
            });
          },
          onPanEnd: (details) {
            widget.onDrop(widget.gameEntity);
          },
          onLongPress: () {
            // Display details about gameEntity function
            widget.onLongPress();
          },
          child: widget.child,
        ));
  }
}
