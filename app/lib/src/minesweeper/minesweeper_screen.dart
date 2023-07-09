// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection' show IterableMixin;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'package:logging/logging.dart' hide Level;

import '../level_selection/levels.dart';

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
    final boardPoint = _board.pointToBoardPoint(scenePoint);
    setState(() {
      _board = _board.copyWithSelected(boardPoint);
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

// CustomPainter is what is passed to CustomPaint and actually draws the scene
// when its `paint` method is called.
class _BoardPainter extends CustomPainter {
  const _BoardPainter({required this.board});

  final Board board;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect boardDims = Rect.fromLTWH(0, 0, 600, 600);
    Paint paint = Paint();
    paint.color = Color.fromARGB(255, 47, 47, 51);
    canvas.drawRect(boardDims, paint);
    void drawPlayers(List<Player> players) {
      for (Player player in players) {
        Paint paint = Paint();
        paint.color = Color.fromARGB(255, 240, 240, 242);
        canvas.drawCircle(Offset(player.x, player.y), 30, paint);
        // final CircleAvatar playerAvatar = CircleAvatar(
        //     backgroundColor: Colors.brown.shade800, child: const Text('AH'));
        // canvas.drawRect(rect, paint);
      }
    }

    drawPlayers(board.players);
    for (Player player in board.players) {
      player.moveRandomly();
    }
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(_BoardPainter oldDelegate) {
    // return oldDelegate.board != board;
    return true;
  }
}

class Player {
  Player(this.x, this.y, {color = const Color.fromARGB(255, 135, 135, 135)});

  double x;
  double y;
  Color color = Color.fromARGB(255, 135, 135, 135);

  @override
  String toString() {
    return 'Player($x, $y, $color)';
  }

  void moveRandomly() {
    double xMovement = Random().nextDouble() - 0.5;
    double yMovement = Random().nextDouble() - 0.5;
    x = x + xMovement;
    y = y + yMovement;
  }

  // Only compares by location.
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is BoardPoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

// The entire state of the hex board and abstraction to get information about
// it. Iterable so that all BoardPoints on the board can be iterated over.
// @immutable
class Board extends Object {
  Board({
    required this.boardWidth,
    required this.boardHeight,
    required this.rectRadius,
    required this.rectMargin,
    // this.players = [],
    // this.selected,

    List<Player> players = const [],
    //2D array, [x-axis, y-axis]
    List<List<BoardPoint>>? boardPoints,
  })  : assert(boardWidth > 0),
        assert(boardHeight > 0),
        assert(rectRadius > 0),
        assert(rectMargin >= 0) {
    // boardPoints = null;
    players = [];
    if (boardPoints != null) {
      _boardPoints = boardPoints;
    } else {
      // Generate boardPoints for a fresh board.
      createPlayers();
      // fillAdjacents();
    }
  }

  final int boardWidth; // Number of cells in the x axis
  final int boardHeight; // Number of cells in the y axis
  final double rectRadius; // Pixel radius of a rectangle (center to vertex).
  final double rectMargin; // Margin between cells.
  final List<Player> players = [];
  // final List<BoardPoint> _boardPoints = <BoardPoint>[];
  // final BoardPoint[][] _boardPoints;
  List<List<BoardPoint>> _boardPoints = [];

  // @override
  // Iterator<BoardPoint?> get iterator => _BoardIterator(_boardPoints);

  // Get the size in pixels of the entire board.
  Size get size {
    return Size((rectRadius + rectMargin) * boardWidth,
        (rectRadius + rectMargin) * boardHeight);
  }

  void createPlayers() {
    int numPlayers = 5;
    for (int i = 0; i < numPlayers; i++) {
      players.add(Player(0, 0));
    }
  }
  // void createBoard() {
  //   double bombChance = 0.06;
  //   final randomNumberGenerator = Random();
  //   for (int x = 0; x < boardWidth; x++) {
  //     List<BoardPoint> columnBoardPoints = [];
  //     for (int y = 0; y < boardHeight; y++) {
  //       final randomDouble = randomNumberGenerator.nextDouble();
  //       bool addBomb = false;
  //       if (randomDouble < bombChance) {
  //         addBomb = true;
  //       }
  //       columnBoardPoints.add(BoardPoint(x, y, false, addBomb));
  //     }
  //     _boardPoints.add(columnBoardPoints);
  //   }
  // }

  void fillAdjacents() {
    for (int x = 0; x < boardWidth; x++) {
      List<BoardPoint> columnBoardPoints = [];
      for (int y = 0; y < boardHeight; y++) {
        List<BoardPoint> adjacentTiles = getAdjacentBoardPoints(x, y);
        BoardPoint currentTile = getBoardPoint(x, y)!;
        int numMines = 0;
        for (final adjacentTile in adjacentTiles) {
          if (adjacentTile.isMine) {
            numMines += 1;
          }
        }
        currentTile.setAdjacentMines(numMines);
      }
      _boardPoints.add(columnBoardPoints);
    }
  }

  bool isValidPoint(int x, int y) {
    return !(x < 0 || y < 0 || x >= boardWidth || y >= boardHeight);
  }

  BoardPoint? getBoardPoint(int x, int y) {
    if (isValidPoint(x, y)) {
      return _boardPoints[x][y];
    }
    return null;
  }

  List<BoardPoint> getBoardPoints() {
    List<BoardPoint> boardPoints = [];
    for (int x = 0; x < boardWidth; x++) {
      for (int y = 0; y < boardHeight; y++) {
        BoardPoint? point = getBoardPoint(x, y);
        if (point != null) {
          boardPoints.add(point);
        }
      }
    }
    return boardPoints;
  }

  List<BoardPoint> getAdjacentBoardPoints(int x, int y) {
    List<BoardPoint> adjacentBoardPoints = [];
    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {
        //Ignore self
        if (i == 0 && j == 0) {
          continue;
        }
        BoardPoint? adjacentBoardPoint = getBoardPoint(x + i, y + j);
        if (getBoardPoint(x + i, y + j) != null) {
          adjacentBoardPoints.add(adjacentBoardPoint!);
        }
      }
    }
    return adjacentBoardPoints;
  }

  // Return the q,r BoardPoint for a point in the scene, where the origin is in
  // the center of the board in both coordinate systems. If no BoardPoint at the
  // location, return null.
  BoardPoint? pointToBoardPoint(Offset point) {
    // TODO clicking on a border, has preference of selecting 1 up and 1 left.
    int xPointed = (point.dx / (rectRadius + rectMargin)).floor();
    int yPointed = (point.dy / (rectRadius + rectMargin)).floor();
    BoardPoint? tappedBoardPoint = getBoardPoint(xPointed, yPointed);

    if (tappedBoardPoint != null) {
      tappedBoardPoint.tapBoardPoint();
    }
    return tappedBoardPoint;
  }

  // Find the top-left corner (in pixels) of the given boardPoint
  Point<double> boardPointToPoint(BoardPoint boardPoint) {
    return Point<double>((rectRadius + rectMargin) * boardPoint.x,
        (rectRadius + rectMargin) * boardPoint.y);
  }

  // Creates a rectangle of where the cell should be drawn given the boardPoint
  Rect getRectForBoardPoint(BoardPoint boardPoint) {
    final boardPointPos = boardPointToPoint(boardPoint);
    return Rect.fromLTWH(
        boardPointPos.x, boardPointPos.y, rectRadius, rectRadius);
  }

  // Return a new board with the given BoardPoint selected.
  Board copyWithSelected(BoardPoint? boardPoint) {
    // if (selected == boardPoint) {
    //   return this;
    // }
    final nextBoard = Board(
      boardWidth: boardWidth,
      boardHeight: boardHeight,
      rectRadius: rectRadius,
      rectMargin: rectMargin,
      // selected: boardPoint,
      boardPoints: _boardPoints,
    );
    return nextBoard;
  }

  // Return a new board where boardPoint has the given color.
  // Board copyWithBoardPointColor(BoardPoint boardPoint, Color color) {
  //   final nextBoardPoint = boardPoint.copyWithColor(color);
  //   final boardPointIndex = _boardPoints.indexWhere((boardPointI) =>
  //   boardPointI.x == boardPoint.x && boardPointI.y == boardPoint.y);
  //
  //   if (elementAt(boardPointIndex) == boardPoint && boardPoint.color == color) {
  //     return this;
  //   }
  //
  //   final nextBoardPoints = List<BoardPoint>.from(_boardPoints);
  //   nextBoardPoints[boardPointIndex] = nextBoardPoint;
  //   final selectedBoardPoint =
  //   boardPoint == selected ? nextBoardPoint : selected;
  //   return Board(
  //     boardWidth: boardWidth,
  //     boardHeight: boardHeight,
  //     rectRadius: rectRadius,
  //     rectMargin: rectMargin,
  //     selected: selectedBoardPoint,
  //     boardPoints: nextBoardPoints,
  //   );
  // }
}

class _BoardIterator extends Iterator<BoardPoint?> {
  _BoardIterator(this.boardPoints);

  final List<BoardPoint> boardPoints;
  int? currentIndex;

  @override
  BoardPoint? current;

  @override
  bool moveNext() {
    if (currentIndex == null) {
      currentIndex = 0;
    } else {
      currentIndex = currentIndex! + 1;
    }

    if (currentIndex! >= boardPoints.length) {
      current = null;
      return false;
    }

    current = boardPoints[currentIndex!];
    return true;
  }
}

// X and Y coordinate board point
// @immutable
class BoardPoint {
  BoardPoint(this.x, this.y, this.isTapped, this.isMine,
      {color = const Color.fromARGB(255, 135, 135, 135)});

  final int x;
  final int y;
  bool isTapped;
  bool isMine;
  // -1 means uninitialized, otherwise indicates adjacent mines including diagonals
  int adjacentMines = -1;
  Color color = Color.fromARGB(255, 135, 135, 135);

  @override
  String toString() {
    return 'BoardPoint($x, $y, $color)';
  }

  void tapBoardPoint() {
    isTapped = true;
    if (isMine) {
      color = Color.fromARGB(255, 170, 20, 20);
    } else {
      color = Color.fromARGB(255, 170, 170, 170);
    }
  }

  void setAdjacentMines(int numAdjacent) {
    adjacentMines = numAdjacent;
  }

  // Only compares by location.
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is BoardPoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  BoardPoint copyWithColor(Color nextColor) =>
      BoardPoint(x, y, isTapped, isMine, color: nextColor);

  // Convert from q,r axial coords to x,y,z cube coords.
  Vector3 get cubeCoordinates {
    return Vector3(
      x.toDouble(),
      y.toDouble(),
      (-x - y).toDouble(),
    );
  }
}
