import 'package:vector_math/vector_math.dart';

import 'descriptors.dart';
import 'doggos.dart';

var players = [
  Doggo(
    name: 'Lucky',
    breed: [Breed.husk],
    breedWeight: [100],
    accessory: [],
    position: Vector2(50, 30),
    motion: Motion(),
    agentStrategy: Strategy.smart,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Brutus',
    breed: [Breed.shep],
    breedWeight: [100],
    accessory: [],
    position: Vector2(750, 750),
    motion: Motion(),
    agentStrategy: Strategy.smart,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Yippy',
    breed: [Breed.chih],
    breedWeight: [100],
    accessory: [],
    position: Vector2(50, 1000),
    motion: Motion(),
    agentStrategy: Strategy.lazy,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Jazz',
    breed: [Breed.chih],
    breedWeight: [100],
    accessory: [],
    position: Vector2(2000, 20),
    motion: Motion(),
    agentStrategy: Strategy.smart,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Sir Ellington the Wise',
    breed: [Breed.pug],
    breedWeight: [100],
    accessory: [],
    position: Vector2(900, 300),
    motion: Motion(),
    agentStrategy: Strategy.close,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Tina',
    breed: [Breed.chih],
    breedWeight: [100],
    accessory: [],
    position: Vector2(1000, 40),
    motion: Motion(),
    agentStrategy: Strategy.close,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
];
