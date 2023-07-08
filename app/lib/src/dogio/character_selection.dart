import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'doggo/players.dart';


class CharacterSelectionScreen extends StatefulWidget {
  CharacterSelectionScreen({super.key});

  @override
  _CharacterSelectionScreen createState() => _CharacterSelectionScreen();
}

class _CharacterSelectionScreen extends State<CharacterSelectionScreen> {
  static final _log = Logger('play_session.dart');

  double _anchor = 0.0;
  bool _center = true;
  final double _velocityFactor = 0.2;
  final double _itemExtent = 120;
  late InfiniteScrollController _controller = InfiniteScrollController();

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
            SizedBox(
              height: 200,
              child: InfiniteCarousel.builder(
                itemCount: players.length,
                itemExtent: _itemExtent,
                center: _center,
                anchor: _anchor,
                velocityFactor: _velocityFactor,
                scrollBehavior: kIsWeb
                    ? ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse
                        },
                      )
                    : null,
                controller: _controller,
                itemBuilder: (context, itemIndex, realIndex) {
                  final currentOffset = _itemExtent * realIndex;
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final diff = (_controller.offset - currentOffset);
                      const maxPadding = 10.0;
                      final _carouselRatio = _itemExtent / maxPadding;

                      return Padding(
                        padding: EdgeInsets.only(
                          top: (diff / _carouselRatio).abs(),
                          bottom: (diff / _carouselRatio).abs(),
                        ),
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: kElevationToShadow[2],
                          image: DecorationImage(
                            image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!_center) ...[
              Text('Selected Item Anchor: ${_anchor.toStringAsFixed(2)}'),
              Slider(
                min: 0.0,
                max: 1.0,
                value: _anchor,
                onChanged: (value) {
                  setState(() {
                    _anchor = value;
                  });
                },
              ),
            ],
            ElevatedButton(
              child: Text('Let\'s go!'),
              onPressed: () {
                print('misha wants to play puzzle: ${_anchor.toStringAsFixed(2)}');
                GoRouter.of(context).go('/play/session/${_anchor.toStringAsFixed(2)}');
              },
            ),
          ],
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            GoRouter.of(context).go('/');
          },
          child: const Text('Home'),
        ),
      ),
    );
  }
}
