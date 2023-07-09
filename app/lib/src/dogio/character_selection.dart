import 'package:carousel_slider/carousel_slider.dart';
import 'package:dogio/src/dogio/doggo/descriptors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;

// import '../style/palette.dart';
import '../asset_controller/images.dart';
import 'doggo/players.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class CharacterSelectionScreen extends StatelessWidget {
  int current = 0;
  @override
  Widget build(BuildContext context) {
    // final palette = context.watch<Palette>();
    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(item, fit: BoxFit.cover, width: 1000.0),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: const [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Text(
                            players[imgList.indexOf(item)].name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Permanent Marker'),
                          ),
                        ),
                      ),
                    ],
                  )),
            ))
        .toList();

    CarouselSlider cs = CarouselSlider(
      options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          onPageChanged: (index, reason) {
            current = index;
          }),
      items: imageSliders,
    );

    return Scaffold(
        appBar: AppBar(title: Text('Select your character')),
        body: Column(children: [
          cs,
          ElevatedButton(
            child: Text('Let\'s go!'),
            onPressed: () {
              // print('player wants to play as doggo $current');
              players[current].agentStrategy = Strategy.none;
              GoRouter.of(context).go('/play');
            },
          ),
        ]));
  }
}

// ignore: use_key_in_widget_constructors
class CharacterSelectionScreenOld extends StatelessWidget {
  // ignore: unused_field
  static final _log = Logger('character_selection.dart');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select your character')),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return CarouselSlider(
            options: CarouselOptions(
              height: height/2,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
            ),
            items: imgList
                .map((item) => Center(
                    child: Image.network(
                      item,
                      fit: BoxFit.cover,
                      height: height/2,
                    )))
                .toList(),
          );
        },
      ),
    );
  }
}
