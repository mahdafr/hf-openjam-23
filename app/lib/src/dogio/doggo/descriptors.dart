enum Breed { husky, shepherd, chihuahua, labrador, pug, poodle }
enum Accessory { glasses, hat, sweater }
enum SpeedMod { accel, decel, none }

class Position {
  double x;
  double y;
  Position({this.x = 0, this.y = 0});
}

class Motion {
  double velocity;
  double boost;
  SpeedMod type;

  double get speed {
    switch ( type ) {
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
