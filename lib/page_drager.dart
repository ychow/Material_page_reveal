import 'dart:async';

import 'package:flutter/material.dart';
import './pager_indicator.dart';

class PageDrager extends StatefulWidget {
  bool canDragLeftToRight;
  bool canDragRightToLeft;
  final StreamController<SlideUpdate> slideUpdateStream;
  
  PageDrager({
    this.canDragLeftToRight,
    this.canDragRightToLeft,
    this.slideUpdateStream,
  });

  @override
  _PageDragerState createState() => _PageDragerState();
}

class _PageDragerState extends State<PageDrager> {
  Offset dragStart;
  SlideDirection slidedirection;
  double slidePercent = 0.0;
  final FULL_TRANSITION_PX = 300.0;

  onDragStart(DragStartDetails details) {
    dragStart = details.globalPosition;
  }

  onDragUpdate(DragUpdateDetails details) {
    if (dragStart != null) {
      final newPosition = details.globalPosition;
      final dx = dragStart.dx - newPosition.dx;
      if (dx > 0 && widget.canDragRightToLeft) {
        slidedirection = SlideDirection.rightToLeft;
      } else if (dx < 0 && widget.canDragLeftToRight) {
        slidedirection = SlideDirection.leftToRight;
      } else {
        slidedirection = SlideDirection.none;
      }

      if (slidedirection != SlideDirection.none) {
        slidePercent = (dx / FULL_TRANSITION_PX).abs().clamp(0.0, 1.0);
      } else {
        slidePercent = 0.0;
      }
      
      widget.slideUpdateStream.add(new SlideUpdate(
        UpdateType.dragging,
        slidedirection, 
        slidePercent
      ));

      print('draging in $slidedirection at $slidePercent%');
    }
  }

  onDragEnd(DragEndDetails details) {
    widget.slideUpdateStream.add(
      new SlideUpdate(
        UpdateType.doneDragging,
        SlideDirection.none,
        0.0,
      )
    );
    dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
    );
  }
}

enum UpdateType {
  dragging,
  doneDragging,
}

class SlideUpdate {
  final updateType;
  final direction;
  final slidePercent;

  SlideUpdate(
    this.updateType,
    this.direction,
    this.slidePercent
  );
}