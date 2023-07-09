// enum Breed { husk, shep, chih, pug, lab, poo }

enum Breed { husk, chih, pug }

enum Accessory { glasses, hat, sweater }

enum SpeedMod { accel, decel, none }

enum Strategy { smart, close, lazy, none }

class Motion {
  double velocity;
  double boost;
  SpeedMod type;

  double get speed {
    switch (type) {
      case SpeedMod.accel:
        return boost * velocity;
      case SpeedMod.decel:
        return -1 * boost * velocity;
      default:
        return velocity;
    }
  }

  Motion({this.velocity = 0, this.boost = 1, this.type = SpeedMod.none});
}
