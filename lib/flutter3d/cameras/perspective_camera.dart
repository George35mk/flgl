import 'package:flgl/flutter3d/math/math_utils.dart';

import 'camera.dart';
import '../math/m4.dart';

class PerspectiveCamera extends Camera {
  double fov;
  double aspect;
  double zNear;
  double zFar;

  PerspectiveCamera(this.fov, [this.aspect = 1, this.zNear = 1, this.zFar = 2000]) {
    double _fov = MathUtils.degToRad(fov);
    projectionMatrix = M4.perspective(_fov, aspect, zNear, zFar);
  }
}
