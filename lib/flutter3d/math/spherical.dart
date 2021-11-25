import 'dart:math' as math;

import 'math_utils.dart';
import 'vector3.dart';

class Spherical {
  double radius;
  double phi;
  double theta;

  Spherical([this.radius = 1, this.phi = 0, this.theta = 0]);

  Spherical set(radius, phi, theta) {
    this.radius = radius;
    this.phi = phi;
    this.theta = theta;

    return this;
  }

  Spherical copy(Spherical other) {
    radius = other.radius;
    phi = other.phi;
    theta = other.theta;

    return this;
  }

  // restrict phi to be betwee EPS and PI-EPS
  Spherical makeSafe() {
    const EPS = 0.000001;
    phi = math.max(EPS, math.min(math.pi - EPS, phi));

    return this;
  }

  Spherical setFromVector3(Vector3 v) {
    return setFromCartesianCoords(v.x, v.y, v.z);
  }

  Spherical setFromCartesianCoords(x, y, z) {
    radius = math.sqrt(x * x + y * y + z * z);

    if (radius == 0) {
      theta = 0;
      phi = 0;
    } else {
      theta = math.atan2(x, z);
      phi = math.acos(MathUtils.clamp(y / radius, -1, 1));
    }

    return this;
  }

  clone() {
    return Spherical().copy(this);
  }
}
