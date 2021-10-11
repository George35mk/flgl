import 'dart:math' as math;
import 'vector3.dart';

class Cylindrical {
  double radius;
  double theta;
  double y;

  Cylindrical([this.radius = 1, this.theta = 0, this.y = 0]);

  Cylindrical set(radius, theta, y) {
    this.radius = radius;
    this.theta = theta;
    this.y = y;

    return this;
  }

  Cylindrical copy(Cylindrical other) {
    radius = other.radius;
    theta = other.theta;
    y = other.y;

    return this;
  }

  Cylindrical setFromVector3(Vector3 v) {
    return setFromCartesianCoords(v.x, v.y, v.z);
  }

  Cylindrical setFromCartesianCoords(x, y, z) {
    radius = math.sqrt(x * x + z * z);
    theta = math.atan2(x, z);
    y = y;

    return this;
  }

  Cylindrical clone() {
    return Cylindrical().copy(this);
  }
}
