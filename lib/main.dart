import 'dart:html';

import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/services.dart';

void main() {
  final breakout = Breakout();
  runApp(
    GameWidget(
      game: breakout,
    ),
  );
}

class Breakout extends Game {
  int ballSpeed = 400;
  static final ballPaint = BasicPalette.white.paint;
  late Rect ballPos;
  
  @override
  Future<void> onLoad() async {
    ballPos = Rect.fromCenter(center: Offset(size.x/2, size.y/2), width: 20, height: 20);
  }

  @override
  void update(double dt) {
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(ballPos, ballPaint);
  }
}