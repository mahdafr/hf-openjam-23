import 'package:collection/collection.dart';
import 'package:vector_math/vector_math.dart';
import 'descriptors.dart';
import 'doggos.dart';

int closest = -1, slowest = -1;

Vector2 calculateMove(int agent, List<Doggo> players, Strategy strat) {
  if ( strat == Strategy.close || strat == Strategy.lazy ) {
    findTargets(agent, players);
  }
  int desired = agent;
  switch ( strat ) {
    case Strategy.lazy:
      desired = slowest;
      break;
    case Strategy.smart:
      // get list of those smaller than you
      var edibles = players.where((doggo) => doggo.size < players[agent].size).toList();
      // // sort by fattest
      // edibles.sort((a, b) => a.size.compareTo(b.size));
      // find the closest
      Vector2 pos = players[agent].position;
      for ( var i = 0; i < edibles.length; i++ ) {
        if ( i==agent ) continue;
        Vector2 dst = players[i].position;
        // find closest
        if ( magnitude(pos, dst) < magnitude(pos, edibles[desired].position) ) {
          desired = i;
        }
      }
      return getUnitVector(players[agent].position, edibles[desired].position);
    default:
      desired = closest;
  }
  return getUnitVector(players[agent].position, players[desired].position);
}

void findTargets(int agent, List<Doggo> players) {
  closest = agent;
  slowest = agent;
  Vector2 pos = players[agent].position;
  for ( var i = 0; i < players.length; i++ ) {
    if ( i==agent ) continue;
    Vector2 dst = players[i].position;
    // find closest
    if ( magnitude(pos, dst) < magnitude(pos, players[closest].position) ) {
      closest = i;
    }
    // find slowest
    if ( getSpeed(players[i]) < getSpeed(players[slowest]) ) {
      slowest = i;
    }
  }
}

double getSpeed(Doggo doggo) {
  return doggo.vel;
}

double magnitude(Vector2 src, Vector2 dst) {
  return src.distanceTo(dst);
}

Vector2 getUnitVector(Vector2 agent, Vector2 target) {
  return (agent - target) / magnitude(agent, target);
}