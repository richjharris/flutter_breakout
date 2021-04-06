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

enum GameState {Playing, Won, Lost}

class Breakout extends Game with HorizontalDragDetector, TapDetector {
  int ballSpeed = 400;
  int paddleSpeed = 400;
  static final ballPaint = BasicPalette.white.paint;
  static final blocksWide = 5;
  static final blocksHigh = 3;
  static final blockHeight = 20.0;
  late Rect ballPos;
  late Rect paddlePos;
  int ballXDirection = 1;
  int ballYDirection = -1;
  bool touchDown = false;
  double touchPosition = 0;
  GameState gameState = GameState.Playing;
  bool leftKeyDown = false;
  bool rightKeyDown = false;
  
  List<List<bool>> blocks = List.generate(blocksHigh, (int index) => List.filled(blocksWide, true, growable: false), growable: false);

  reset() {
    gameState = GameState.Playing;
    ballPos = Rect.fromCenter(center: Offset(size.x/2, size.y/2), width: 20, height: 20);
    paddlePos = Rect.fromCenter(center: Offset(size.x/2, size.y - 20), width: 100, height: 20);
    ballXDirection = 1;
    ballYDirection = -1;
    for (int i = 0; i < blocks.length; ++i) {
      for (int j = 0; j < blocks[i].length; ++j) {
        blocks[i][j] = true;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    reset();
    RawKeyboard.instance.addListener((RawKeyEvent e) {
      final bool isKeyDown = e is RawKeyDownEvent;
      if (gameState != GameState.Playing) {
        if (isKeyDown && (e.logicalKey == LogicalKeyboardKey.space || e.logicalKey == LogicalKeyboardKey.enter)) {
          reset();
          return;
        }
      }
      final bool isKeyUp = e is RawKeyUpEvent;
      print('isKeyUp ${isKeyUp} isLeft ${e.logicalKey == LogicalKeyboardKey.arrowLeft}');
      if (isKeyDown && e.logicalKey == LogicalKeyboardKey.arrowLeft) {
        leftKeyDown = true;
      } else if (isKeyUp && e.logicalKey == LogicalKeyboardKey.arrowLeft) {
        leftKeyDown = false;
      } else if (isKeyDown && e.logicalKey == LogicalKeyboardKey.arrowRight) {
        rightKeyDown = true;
      } else if (isKeyUp && e.logicalKey == LogicalKeyboardKey.arrowRight) {
        rightKeyDown = false;
      }
    });
  }

  @override
  void update(double dt) {
    if (gameState != GameState.Playing) {
      return;
    }
    if (touchDown || leftKeyDown || rightKeyDown) {
      double delta = paddleSpeed * dt;
      if (touchDown) {
        if ((paddlePos.center.dx - touchPosition).abs() < delta) {
          delta = (paddlePos.center.dx - touchPosition).abs();
        }
        if (paddlePos.center.dx > touchPosition) {
          delta *= -1;
        }
      } else if (leftKeyDown) {
        delta *= -1;
      }
      paddlePos = paddlePos.translate(delta, 0);
    }
    ballPos = ballPos.translate(ballSpeed * ballXDirection * dt, ballSpeed * ballYDirection * dt);

    if (ballYDirection == -1) {
      double width = size.x / blocksWide;
      for (int i = 0; i < blocks.length; ++i) {
        for (int j = 0; j < blocks[i].length; ++j) {
          if (blocks[i][j]) {
            if (Rect.fromLTWH(width * j, blockHeight * i, width, blockHeight).deflate(1).overlaps(ballPos)) {
              print('intersect ${i}, ${j}');
              print('pre blocks[0][j] ${blocks[0][j]}');
              blocks[i][j] = false;
              print('blocks[i][j] ${blocks[i][j]}');
              print('blocks[0][j] ${blocks[0][j]}');
              ballYDirection = 1;
              return;
            }
          }
        }
      }
    } else {
      if (paddlePos.overlaps(ballPos)) {
        ballYDirection = -1;
      }
    }

    if (ballXDirection == 1 && ballPos.right > size.x) {
      ballXDirection = -1;
    } else if (ballXDirection == -1 && ballPos.left < 0) {
      ballXDirection = 1;
    }

    if (ballPos.top < 0) {
      gameState = GameState.Won;
    } else if (ballPos.bottom > size.y) {
      gameState = GameState.Lost;
    }
  }

  @override
  void render(Canvas canvas) {
    if (gameState != GameState.Playing) {
      final String text = gameState == GameState.Won ? 'You Won!' : 'You Lost!';
      TextSpan span = new TextSpan(style: new TextStyle(color: Colors.white, fontSize: 100), text: text);
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, new Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2));
      return;
    }
    double width = size.x / blocksWide;
    for (int i = 0; i < blocks.length; ++i) {
      for (int j = 0; j < blocks[i].length; ++j) {
        if (blocks[i][j]) {
          canvas.drawRect(Rect.fromLTWH(width * j, blockHeight * i, width, blockHeight).deflate(1), ballPaint);
        }
      }
    }
    canvas.drawRect(ballPos, ballPaint);
    canvas.drawRect(paddlePos, ballPaint);
  }

  void handleTouch(x) {
    touchDown = true;
    touchPosition = x;
  }

  @override
  void onHorizontalDragEnd(DragEndDetails details) {
    touchDown = false;
  }

  @override
  void onHorizontalDragUpdate(DragUpdateDetails details) {
    this.handleTouch(details.globalPosition.dx);
  }

  @override
  void onTap() {
    reset();
  }
}