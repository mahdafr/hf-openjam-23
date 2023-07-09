// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import '../dogio/doggo/descriptors.dart';

List<String> soundTypeToFilename(Breed breed) {
  switch (breed) {
    case Breed.chih:
      return ['chih.wav'];
    case Breed.husk:
      return ['husk.wav'];
    case Breed.pug:
      return ['pug.wav'];
    default:
      return ['pug.wav', 'chih.wav', 'husk.wav'];
  }
}

/// Allows control over loudness of different SFX types.
double soundTypeToVolume(Breed breed) {
  switch (breed) {
    case Breed.chih:
      return 0.4;
    case Breed.pug:
      return 0.2;
    default:
      return 1.0;
  }
}

