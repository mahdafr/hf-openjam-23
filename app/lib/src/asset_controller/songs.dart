// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const Set<Song> songs = {
  // Filenames with whitespace break package:audioplayers on iOS
  // (as of February 2022), so we use no whitespace.
  Song('background0.mp3', 'Azul', artist: 'UNKNOWN'),
  Song('background1.mp3', 'Sonorus', artist: 'UNKNOWN'),
  Song('background2.mp3', 'SundaySolitude', artist: 'UNKNOWN'),
};

class Song {
  final String filename;
  final String name;
  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'background<$filename>';
}
