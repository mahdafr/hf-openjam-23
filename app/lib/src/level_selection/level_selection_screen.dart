// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../asset_controller/audio_controller.dart';
import '../dogio/doggo/descriptors.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'levels.dart';

class LevelSelectionScreenOld extends StatelessWidget {
  const LevelSelectionScreenOld({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();

    return Scaffold(
      backgroundColor: palette.backgroundSelection,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Select puzzle',
                  style:
                      TextStyle(fontFamily: 'Permanent Marker', fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: ListView(
                children: [
                  for (final level in gameLevels)
                    ListTile(
                      enabled: playerProgress.highestLevelReached >=
                          level.number - 1,
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(Breed.lab);

                        GoRouter.of(context)
                            .go('/play/session/${level.number}');
                      },
                      leading: Text(level.number.toString()),
                      title: Text(level.name + (level.number>0 ? level.number.toString() : '')),
                    ),
                    ListTile(
                      enabled: playerProgress.highestLevelReached >=
                          1,
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(Breed.husk);

                        GoRouter.of(context)
                            .go('/play/session/minesweeper/${2}');
                      },
                      leading: Text(6.toString()),
                      title: Text('Level #${12}'),
                    )

                ],
              ),
            ),
          ],
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            GoRouter.of(context).go('/');
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}
