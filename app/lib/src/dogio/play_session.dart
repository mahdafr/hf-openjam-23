// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'doggo/players.dart';

class PlaySessionScreen extends StatefulWidget {
  final int maxScore = 1000;

  const PlaySessionScreen({super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreen();
}

class _PlaySessionScreen extends State<PlaySessionScreen> {
  static final _log = Logger('play_session.dart');

  static const _celebrationDuration = Duration(milliseconds: 2000);
  static const _preCelebrationDuration = Duration(milliseconds: 500);
  bool _duringCelebration = false;
  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.maxScore,
            onWin: _playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundSession,
          body: Stack(
            children: [
              Center(
                // This is the entirety of the "game".
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkResponse(
                        onTap: () => GoRouter.of(context).push('/settings'),
                        child: Image.asset(
                          'assets/images/settings.png',
                          semanticLabel: 'Settings',
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('Drag the slider to ${widget.maxScore} or above!'),
                    // TODO not a slider
                    Consumer<LevelState>(
                      builder: (context, levelState, child) => Slider(
                        label: 'Level Progress',
                        autofocus: true,
                        value: levelState.progress / 100,
                        onChanged: (value) =>
                            levelState.setProgress((value * 100).round()),
                        onChangeEnd: (value) => levelState.evaluate(),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => GoRouter.of(context).go('/select'),
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !_duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  Future<void> _playerWon() async {
    _log.info('Player ${players[0]} won');

    final score = Score(
      widget.maxScore,
      widget.maxScore,
      DateTime.now().difference(_startOfPlay),
    );

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(widget.maxScore);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      if (players[0].awardsAchievement) {
        await gamesServicesController.awardAchievement(
          android: players[0].achievementIdAndroid!,
          iOS: players[0].achievementIdIOS!,
        );
      }

      // Send score to leaderboard.
      await gamesServicesController.submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
