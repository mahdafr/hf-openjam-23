// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:collection' show IterableMixin;
import 'dart:math';
import 'dart:ui';
import 'package:dogio/src/dogio/doggo/doggos.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'package:logging/logging.dart' hide Level;

import '../level_selection/levels.dart';
import '../dogio/doggo/players.dart';

class MinesweeperScreen extends StatefulWidget {
  // final GameLevel level;

  const MinesweeperScreen({super.key});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreen();
}

class _MinesweeperScreen extends State<MinesweeperScreen>
    with TickerProviderStateMixin {
  static final _log = Logger('DogBoardScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  late DateTime _startOfPlay;
  final GlobalKey _targetKey = GlobalKey();
  // The radius of a Rectangle tile in pixels.
  static const _kRectRadius = 16.0;
  // The size border between cells.
  static const _kRectBorder = 1.0;
  // The radius of the entire board in hexagons, not including the center.
  static const _kBoardWidth = 16;
  static const _kBoardHeight = 30;

  Board _board = Board(
    boardWidth: _kBoardWidth,
    boardHeight: _kBoardHeight,
    rectRadius: _kRectRadius,
    rectMargin: _kRectBorder,
  );

  final TransformationController _transformationController =
      TransformationController();
  Animation<Matrix4>? _animationReset;
  late AnimationController _controllerReset;
  Matrix4? _homeMatrix;

  // Handle reset to home transform animation.
  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset?.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  // Initialize the reset to home transform animation.
  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: _homeMatrix,
    ).animate(_controllerReset);
    _controllerReset.duration = const Duration(milliseconds: 400);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  // Stop a running reset to home transform animation.
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  void _onScaleStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  void _onTapUp(TapUpDetails details) {
    final renderBox =
        _targetKey.currentContext!.findRenderObject() as RenderBox;
    final offset =
        details.globalPosition - renderBox.localToGlobal(Offset.zero);
    final scenePoint = _transformationController.toScene(offset);
    // final boardPoint = _board.pointToBoardPoint(scenePoint);
    setState(() {
      // _board = _board.copyWithSelected(boardPoint);
    });
  }

  @override
  void initState() {
    super.initState();
    _controllerReset = AnimationController(
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The scene is drawn by a CustomPaint, but user interaction is handled by
    // the InteractiveViewer parent widget.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("It's a dog eat dog world out there"),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Draw the scene as big as is available, but allow the user to
            // translate beyond that to a visibleSize that's a bit bigger.
            final viewportSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            // Start the first render, start the scene centered in the viewport.
            if (_homeMatrix == null) {
              _homeMatrix = Matrix4.identity()
                ..translate(
                  viewportSize.width / 2 - _board.size.width / 2,
                  viewportSize.height / 2 - _board.size.height / 2,
                );
              _transformationController.value = _homeMatrix!;
            }

            return ClipRect(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: _onTapUp,
                  child: InteractiveViewer(
                    key: _targetKey,
                    transformationController: _transformationController,
                    boundaryMargin: EdgeInsets.symmetric(
                      horizontal: viewportSize.width,
                      vertical: viewportSize.height,
                    ),
                    minScale: 0.01,
                    onInteractionStart: _onScaleStart,
                    child: SizedBox.expand(
                      child: CustomPaint(
                        size: _board.size,
                        painter: _BoardPainter(
                          board: _board,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      persistentFooterButtons: [resetButton],
    );
  }

  IconButton get resetButton {
    return IconButton(
      onPressed: () {
        setState(() {
          _animateResetInitialize();
        });
      },
      tooltip: 'Reset',
      color: Theme.of(context).colorScheme.surface,
      icon: const Icon(Icons.replay),
    );
  }
}

class TimerNotifier extends ChangeNotifier {
  TimerNotifier() {
    const Duration oneSec = Duration(milliseconds: 20);
    Timer.periodic(oneSec, notifyAllListeners);
  }

  void notifyAllListeners(Timer time) {
    notifyListeners();
  }
}

// CustomPainter is what is passed to CustomPaint and actually draws the scene
// when its `paint` method is called.
class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.board}) : super(repaint: TimerNotifier()) {}

  final Board board;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect boardDims = Rect.fromLTWH(0, 0, 600, 600);
    Paint paint = Paint();
    paint.color = Color.fromARGB(255, 47, 47, 51);
    canvas.drawRect(boardDims, paint);

    void drawPlayers(List<Doggo> players) {
      for (Doggo player in players) {
        Paint paint = Paint();
        paint.color = Color.fromARGB(255, 240, 240, 242);
        canvas.drawCircle(Offset(player.x, player.y), 30, paint);
      }
    }

    drawPlayers(board.dogPlayers);
    for (Doggo player in board.dogPlayers) {
      List<double> newCoords = moveRandomly(player, board.dogPlayers);
      //TODO from unit vector, use velocity to find new position
      player.position.x = newCoords[0];
      player.position.y = newCoords[1];
    }
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(_BoardPainter oldDelegate) {
    return true;
  }
}

List<double> moveRandomly(Doggo player, List<Doggo> players) {
  double xMovement = Random().nextDouble() - 0.5;
  double yMovement = Random().nextDouble() - 0.5;
  double newX = player.x + xMovement;
  double newY = player.y + yMovement;
  return [newX, newY];
}

// class Player {
//   Player(this.x, this.y, {color = const Color.fromARGB(255, 135, 135, 135)});

//   double x;
//   double y;
//   Color color = Color.fromARGB(255, 135, 135, 135);

//   @override
//   String toString() {
//     return 'Player($x, $y, $color)';
//   }

//   void moveRandomly() {
//     double xMovement = Random().nextDouble() - 0.5;
//     double yMovement = Random().nextDouble() - 0.5;
//     x = x + xMovement;
//     y = y + yMovement;
//   }

//   @override
//   int get hashCode => Object.hash(x, y);
// }

// The entire state of the hex board and abstraction to get information about
// it. Iterable so that all BoardPoints on the board can be iterated over.
// @immutable
class Board extends Object {
  Board({
    required this.boardWidth,
    required this.boardHeight,
    required this.rectRadius,
    required this.rectMargin,
    List<Doggo> players = const [],
  })  : assert(boardWidth > 0),
        assert(boardHeight > 0),
        assert(rectRadius > 0),
        assert(rectMargin >= 0) {}

  final int boardWidth; // Number of cells in the x axis
  final int boardHeight; // Number of cells in the y axis
  final double rectRadius; // Pixel radius of a rectangle (center to vertex).
  final double rectMargin; // Margin between cells.
  final List<Doggo> dogPlayers = players;

  // Get the size in pixels of the entire board.
  Size get size {
    return Size((rectRadius + rectMargin) * boardWidth,
        (rectRadius + rectMargin) * boardHeight);
  }

  bool isValidPoint(int x, int y) {
    return !(x < 0 || y < 0 || x >= boardWidth || y >= boardHeight);
  }

  // Return a new board with the given BoardPoint selected.
  Board copyWithSelected() {
    final nextBoard = Board(
      boardWidth: boardWidth,
      boardHeight: boardHeight,
      rectRadius: rectRadius,
      rectMargin: rectMargin,
    );
    return nextBoard;
  }
}
