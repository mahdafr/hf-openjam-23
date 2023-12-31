// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:math';

import 'package:dogio/src/dogio/doggo/doggos.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:vector_math/vector_math.dart' show Vector2;

import '../dogio/doggo/ai_move.dart';
import '../dogio/doggo/descriptors.dart';
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

  // The radius of the entire board in hexagons, not including the center.
  static const _kBoardWidth = 2500.0;
  static const _kBoardHeight = 1200.0;

  final Board _board = Board(
    boardWidth: _kBoardWidth,
    boardHeight: _kBoardHeight,
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
    _board.pointToDirection(scenePoint);
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
  _BoardPainter({required this.board}) : super(repaint: TimerNotifier());

  final Board board;

  @override
  void paint(Canvas canvas, Size size) {
    // final Rect boardDims =
    //     Rect.fromLTWH(0, 0, board.boardWidth, board.boardHeight);
    // final Rect boardDims = Rect.fromLTWH(board.boardWidth / -2,
    //     board.boardHeight / -2, board.boardWidth / 2, board.boardHeight / 2);
    final Rect boardDims =
        Rect.fromLTWH(0, 0, board.boardWidth, board.boardHeight);
    Paint paint = Paint();
    paint.color = Color.fromARGB(255, 47, 47, 51);
    canvas.drawRect(boardDims, paint);

    void drawPlayers(List<Doggo> players) {
      for (Doggo player in players) {
        Paint paint = Paint();
        paint.color = Color.fromARGB(255, 240, 240, 242);
        if (player == board.findPlayer()) {
          paint.color = Color.fromARGB(255, 0, 125, 31);
        }
        canvas.drawCircle(Offset(player.x, player.y), player.size, paint);
      }
    }

    drawPlayers(board.dogPlayers);
    int playerId = 0;
    for (Doggo player in board.dogPlayers) {
      Vector2 vectorMovement = Vector2(0, 0);
      if (player.strategy == Strategy.none) {
        vectorMovement = board.playerDirection;
      } else {
        vectorMovement = calculateMove(playerId, players, Strategy.smart);
      }
      // List<double> newCoords = moveRandomly(player, board.dogPlayers);

      //TODO from unit vector, use velocity to find new position
      player.position.x += vectorMovement.x;
      player.position.y += vectorMovement.y;
      if (player.position.x < 0) {
        player.position.x = 0;
      }
      if (player.position.y < 0) {
        player.position.y = 0;
      }

      if (player.position.x > board.boardWidth) {
        player.position.x = board.boardWidth;
      }
      if (player.position.y > board.boardHeight) {
        player.position.y = board.boardHeight;
      }

      playerId += 1;
    }

    // Collision checking
    for (Doggo player1 in board.dogPlayers) {
      for (Doggo player2 in board.dogPlayers) {
        if (player1 == player2) {
          continue;
        }
        // Finding collision between 2 players can be done by finding the
        // smaller player, getting the unit vector, multiplying it by it's size,
        // and then checking if that position is inside the larger player
        Doggo smallerPlayer = player1;
        Doggo largerPlayer = player2;
        if (player2.size < smallerPlayer.size) {
          smallerPlayer = player2;
          largerPlayer = player1;
        }
        Vector2 unitVec =
            getUnitVector(smallerPlayer.position, largerPlayer.position);
        Vector2 smallerPlayerMagnitude = unitVec * smallerPlayer.size;
        Vector2 smallerPlayerEdge =
            smallerPlayer.position + smallerPlayerMagnitude;
        num circleEquation = pow(smallerPlayerEdge.x - largerPlayer.x, 2) +
            pow(smallerPlayerEdge.y - largerPlayer.y, 2);

        if (circleEquation < largerPlayer.size) {
          collision(smallerPlayer, largerPlayer);
        }
      }
    }
    addPoints(players, 0.002);
    if (isWinner(board.dogPlayers, 500)) {}
  }

  bool isWinner(List<Doggo> dogPlayers, double winningScore) {
    for (Doggo player in dogPlayers) {
      if (player.size > winningScore) {
        return true;
      }
    }
    return false;
  }

  void collision(Doggo player1, Doggo player2) {
    void playerEat(Doggo playerWhoAte, Doggo playerEaten) {
      killPlayer(playerEaten);
      double playerArea = pi * pow(playerWhoAte.size, 2);
      double areaWon = pi * pow(playerEaten.size, 2);
      double newRadius = sqrt((playerArea + areaWon) / pi);
      playerWhoAte.size = newRadius;
    }

    if (player1.size < player2.size) {
      playerEat(player2, player1);
    } else {
      playerEat(player1, player2);
    }
  }

  void killPlayer(Doggo player) {
    var rng = Random();
    player.position.x = rng.nextInt(1000).toDouble();
    player.position.y = rng.nextInt(1000).toDouble();
  }

  void addPoints(List<Doggo> dogPlayers, double points) {
    for (Doggo player in dogPlayers) {
      player.size += points;
    }
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(_BoardPainter oldDelegate) {
    return true;
  }
}

// The entire state of the hex board and abstraction to get information about
// it. Iterable so that all BoardPoints on the board can be iterated over.
// @immutable
class Board extends Object {
  Board({
    required this.boardWidth,
    required this.boardHeight,
    // required this.rectRadius,
    // required this.rectMargin,
    List<Doggo> players = const [],
  })  : assert(boardWidth > 0),
        assert(boardHeight > 0)
  // assert(rectRadius > 0),
  // assert(rectMargin >= 0)
  ;
  final double boardWidth; // Number of cells in the x axis
  final double boardHeight; // Number of cells in the y axis
  // final double rectRadius; // Pixel radius of a rectangle (center to vertex).
  // final double rectMargin; // Margin between cells.
  final List<Doggo> dogPlayers = players;
  Vector2 playerDirection = Vector2(0, 0);

  // Get the size in pixels of the entire board.
  Size get size {
    return Size(boardWidth + 30, boardHeight + 30);
  }

  Doggo findPlayer() {
    for (Doggo player in dogPlayers) {
      if (player.strategy == Strategy.none) {
        return player;
      }
    }
    return dogPlayers[0];
  }

  void pointToDirection(Offset point) {
    Vector2 targetDirection = Vector2(point.dx, point.dy);
    playerDirection = getUnitVector(findPlayer().position, targetDirection);
  }

  bool isValidPoint(int x, int y) {
    return !(x < 0 || y < 0 || x >= boardWidth || y >= boardHeight);
  }

  // Return a new board with the given BoardPoint selected.
  Board copyWithSelected() {
    final nextBoard = Board(
      boardWidth: boardWidth,
      boardHeight: boardHeight,
      // rectRadius: rectRadius,
      // rectMargin: rectMargin,
    );
    return nextBoard;
  }
}
