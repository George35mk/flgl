import 'camera.dart';
import '../math/m4.dart';

class OrthographicCamera extends Camera {
  double left;
  double right;
  double bottom;
  double top;
  double near;
  double far;

  double orthographicSize = 1;
  double aspectRatio = 1;

  OrthographicCamera(this.left, this.right, this.bottom, this.top, this.near, this.far) {
    projectionMatrix = M4.orthographic(left, right, bottom, top, near, far);
  }

  setViewportSize(double width, double height) {
    aspectRatio = width / height;
    recalculateProjection();
  }

  setOrthographic(double size, double nearPlane, double farPlane) {
    orthographicSize = size;
    near = nearPlane;
    far = farPlane;
    recalculateProjection();
  }

  recalculateProjection() {
    left = -orthographicSize * aspectRatio * 0.5;
    right = orthographicSize * aspectRatio * 0.5;
    bottom = -orthographicSize * 0.5;
    top = orthographicSize * 0.5;

    projectionMatrix = M4.orthographic(left, right, bottom, top, near, far);
  }


}
