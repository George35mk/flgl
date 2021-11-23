import 'camera.dart';
import '../math/m4.dart';

class OrthographicCamera extends Camera {
  double left;
  double right;
  double bottom;
  double top;
  double near;
  double far;

  OrthographicCamera(this.left, this.right, this.bottom, this.top, this.near, this.far) {
    projectionMatrix = M4.orthographic(left, right, bottom, top, near, far);
  }

  zoom(double zoom) {
    // viewMatrix = M4.translate(viewMatrix, -position.x, -position.y, 0);
    // viewMatrix = M4.scale(viewMatrix, zoom, zoom, 1.0);
    // viewMatrix = M4.translate(viewMatrix, right, top, 1.0);
  }
}
