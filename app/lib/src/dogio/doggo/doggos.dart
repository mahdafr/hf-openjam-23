import 'descriptors.dart';

class Doggo {
  final String name;
  var breed = <Breed>[];
  var breedWeight = <double>[];
  var accessory = <Accessory>[];

  final int breedWeightMax = 100;
  int size;

  int get maxWeight => breedWeightMax;
  Breed get starterBreed => breed[0];
  int get numBreeds => breed.length;

  Position position;
  Motion motion;
  double get x => position.x;
  double get y => position.y;
  double get vel => motion.velocity;

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
    this.achievementIdIOS,
    this.achievementIdAndroid,
    this.size = 1,
  }): assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');
}
