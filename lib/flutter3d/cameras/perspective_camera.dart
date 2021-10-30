import 'camera.dart';
import '../math/m4.dart';

// double fov = MathUtils.degToRad(60);
// double aspect = (width * dpr) / (height * dpr);
// double zNear = 1;
// double zFar = 2000;
// var projectionMatrix = M4.perspective(fov, aspect, zNear, zFar);

// // Compute the camera's matrix
// var camera = [0, 0, 100];
// var target = [0, 0, 0];
// var up = [0, 1, 0];
// var cameraMatrix = M4.lookAt(camera, target, up);

// // Make a view matrix from the camera matrix.
// var viewMatrix = M4.inverse(cameraMatrix);

class PerspectiveCamera extends Camera {
  double fov;
  double aspect;
  double zNear;
  double zFar;

  List<num> projectionMatrix = M4.identity();

  PerspectiveCamera(this.fov, [this.aspect = 1, this.zNear = 1, this.zFar = 2000]) {
    projectionMatrix = M4.perspective(fov, aspect, zNear, zFar);
  }
}
