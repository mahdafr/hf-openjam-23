import 'package:vector_math/vector_math.dart';

import 'descriptors.dart';
import 'doggos.dart';



var players = [
  Doggo(
    name: 'Lucky',
    breed: [Breed.husky],
    breedWeight: [100],
    accessory: [],
    position: Vector2(100, 100),
    motion: Motion(),
    agentStrategy: Strategy.smart,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Grover',
    breed: [Breed.shepherd],
    breedWeight: [100],
    accessory: [],
    position: Vector2(150, 150),
    motion: Motion(),
    agentStrategy: Strategy.smart,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Brutus',
    breed: [Breed.chihuahua],
    breedWeight: [100],
    accessory: [],
    position: Vector2(50, 50),
    motion: Motion(),
    agentStrategy: Strategy.lazy,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Jazz',
    breed: [Breed.labrador],
    breedWeight: [100],
    accessory: [],
    position: Vector2(75, 75),
    motion: Motion(),
    agentStrategy: Strategy.smart,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Max',
    breed: [Breed.pug],
    breedWeight: [100],
    accessory: [],
    position: Vector2(200, 200),
    motion: Motion(),
    agentStrategy: Strategy.close,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  Doggo(
    name: 'Tina',
    breed: [Breed.poodle],
    breedWeight: [100],
    accessory: [],
    position: Vector2(250, 250),
    motion: Motion(),
    agentStrategy: Strategy.close,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
];