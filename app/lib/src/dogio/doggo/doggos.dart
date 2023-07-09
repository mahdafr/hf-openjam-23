import 'package:vector_math/vector_math.dart';
import '../../asset_controller/images.dart';
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

Breed getBreedAt(Doggo doggo, int index) {
  return doggo.breed[index];
}

String getImageName(Doggo doggo) {
  String s = pref;
  for (int i = 0; i < doggo.numBreeds; i++) {
    s = s + rtImgList[getBreedAt(doggo, i).index];
    if (i + 1 < doggo.numBreeds) {
      s = s + sep;
    }
  }
  return s + suf;
}

bool addNewBreed(Doggo eater, Doggo victim) {
  for (int i = 0; i < eater.numBreeds; i++) {
    if (eater.breed[i] == victim.breed) {
      return false;
    }
  }
  return true;
}
