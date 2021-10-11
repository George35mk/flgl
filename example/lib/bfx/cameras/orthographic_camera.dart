import 'package:flgl_example/bfx/cameras/camera.dart';

class OrthographicCamera extends Camera {
  bool isOrthographicCamera = true;

  /// Camera frustum left plane.
  double left;

  /// Camera frustum right plane.
  double right;

  /// Camera frustum top plane.
  double top;

  /// Camera frustum bottom plane.
  double bottom;

  /// Camera frustum near plane. Default is 0.1.
  /// The valid range is between 0 and the current value of the far plane.
  /// Note that, unlike for the PerspectiveCamera, 0 is a valid value for
  /// an OrthographicCamera's near plane.
  double near;

  /// Camera frustum far plane. Default is 2000.
  /// Must be greater than the current value of near plane.
  double far;

  /// Gets or sets the zoom factor of the camera. Default is 1.
  double zoom = 1;

  /// Set by setViewOffset. Default is null.
  dynamic view;

  OrthographicCamera([this.left = -1, this.right = 1, this.top = 1, this.bottom = -1, this.near = 0.1, this.far = 2000])
      : super() {
    type = 'OrthographicCamera';
    name = '';

    updateProjectionMatrix();
  }

  @override
  OrthographicCamera copy(dynamic source, [bool recursive = true]) {
    super.copy(source, recursive);

    left = source.left;
    right = source.right;
    top = source.top;
    bottom = source.bottom;
    near = source.near;
    far = source.far;

    zoom = source.zoom;
    view = source.view ?? {};

    return this;
  }

  void setViewOffset(double fullWidth, double fullHeight, double x, double y, double width, double height) {
    view ??= {
      'enabled': true,
      'fullWidth': 1,
      'fullHeight': 1,
      'offsetX': 0,
      'offsetY': 0,
      'width': 1,
      'height': 1,
    };

    view['enabled'] = true;
    view['fullWidth'] = fullWidth;
    view['fullHeight'] = fullHeight;
    view['offsetX'] = x;
    view['offsetY'] = y;
    view['width'] = width;
    view['height'] = height;

    updateProjectionMatrix();
  }

  /// Removes any offset set by the .setViewOffset method.
  void clearViewOffset() {
    if (view != null) {
      view['enabled'] = false;
    }

    updateProjectionMatrix();
  }

  /// Updates the camera projection matrix. Must be called after any change of parameters.
  void updateProjectionMatrix() {
    final dx = (this.right - this.left) / (2 * zoom);
    final dy = (this.top - this.bottom) / (2 * zoom);
    final cx = (this.right + this.left) / 2;
    final cy = (this.top + this.bottom) / 2;

    var left = cx - dx;
    var right = cx + dx;
    var top = cy + dy;
    var bottom = cy - dy;

    if (view != null && view['enabled']) {
      final scaleW = (this.right - this.left) / view['fullWidth'] / zoom;
      final scaleH = (this.top - this.bottom) / view['fullHeight'] / zoom;

      left += scaleW * view['offsetX'];
      right = left + scaleW * view['width'];
      top -= scaleH * view['offsetY'];
      bottom = top - scaleH * view['height'];
    }

    projectionMatrix.makeOrthographic(left, right, top, bottom, near, far);
    projectionMatrixInverse.copy(projectionMatrix).invert();
  }

  /// meta -- object containing metadata such as textures or images in objects' descendants.
  /// Convert the camera to three.js JSON Object/Scene format.
  toJSON(meta) {
    print('Not implemented');
    // const data = super.toJSON(meta);

    // data.object.zoom = zoom;
    // data.object.left = left;
    // data.object.right = right;
    // data.object.top = top;
    // data.object.bottom = bottom;
    // data.object.near = near;
    // data.object.far = far;

    // if (this.view != null) data.object.view = Object.assign({}, this.view);

    // return data;
  }
}
