import 'package:flgl_example/bfx/cameras/camera.dart';
import 'package:flgl_example/bfx/scene.dart';

class OpenGLESRenderer {
  late Scene scene;
  late Camera camera;

  // OpenGLContextES gl
  OpenGLESRenderer(gl);

  /// on render init you must get the program info
  /// for each object in scene get the geometry and material
  /// from geometry get the:
  /// - positions
  /// - normals
  /// - and uv's
  /// From material get the color and compute the color vertices.
  init() {
    //
  }

  render(Scene scene, Camera camera) {
    print('Render');

    /// update scene matrix world
    /// update camera matrix world
    ///
    /// then make 3 lists of:
    /// - opaque objects
    ///
    /// - transparent objects are the last

    if (scene.autoUpdate) {
      scene.updateMatrixWorld();
    }
    if (camera.parent == null) camera.updateMatrixWorld();
  }

  renderScene() {
    // renderObjects()
  }

  renderObjects() {
    /// For each object in render list call renderObject()
  }

  renderObject() {
    // renderBufferDirect()
  }

  renderBufferDirect() {
    //
  }
}

class WebGLBufferRenderer {
  dynamic gl;
  dynamic extensions;
  dynamic info;
  dynamic capabilities;
  dynamic mode;

  WebGLBufferRenderer(this.gl, this.extensions, this.info, this.capabilities);

  // setMode(gl.TRIANGLES);
  setMode() {
    //
  }

  render(start, count) {
    gl.drawArrays(mode, start, count);
    info.update(count, mode, 1);
  }
}

class WebGLIndexedBufferRenderer {
  WebGLIndexedBufferRenderer();
}
