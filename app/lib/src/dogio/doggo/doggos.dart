import 'package:vector_math/vector_math.dart';
import 'descriptors.dart';

class Doggo {
  final String name;
  var breed = <Breed>[];
  var breedWeight = <double>[];
  var accessory = <Accessory>[];

  final int breedWeightMax = 100;
  double size;

  int get maxWeight => breedWeightMax;
  Breed get starterBreed => breed[0];
  int get numBreeds => breed.length;

  Vector2 position;
  Motion motion;
  double get x => position.x;
  double get y => position.y;
  double get vel => motion.velocity;

  Strategy agentStrategy;

  Strategy get strategy => agentStrategy;

  /// The achievement to unlock when the level is finished, if any.
  final String? achievementIdIOS;
  final String? achievementIdAndroid;
  bool get awardsAchievement => achievementIdAndroid != null;

  Doggo({
    required this.name,
    required this.breed,
    required this.breedWeight,
    required this.accessory,
    required this.position,
    required this.motion,
    this.agentStrategy = Strategy.none,
    this.achievementIdIOS,
    this.achievementIdAndroid,
    this.size = 5,
  }) : assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');
}
