import 'package:flgl/flgl.dart';
import 'package:flgl/flutter3d/geometries/edged_box_geometry.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../cameras/camera.dart';
import '../flutter3d.dart';
import '../scene.dart';

class Renderer {
  /// The flgl instance.
  Flgl flgl;

  /// The OpenGLES context instance.
  OpenGLContextES gl;

  /// The viewport width.
  double width = 0;

  /// The viewport height.
  double height = 0;

  /// The viewport aspect ratio.
  double dpr = 1.0;

  /// The scene background color.
  final List<double> _backgroundColor = [0, 0, 0, 1];

  Renderer(this.gl, this.flgl);

  dispose() {}

  /// Sets the viewport width.
  void setWidth(double width) {
    this.width = width;
  }

  /// Set's the viewport height.
  void setHeight(double height) {
    this.height = height;
  }

  /// Set's the device pixel ration.
  void setDPR(double dpr) {
    this.dpr = dpr;
  }

  /// Set's the scene background color.
  /// - r: the red value. 0 - 1
  /// - g: the green value. 0 - 1
  /// - b: the blue value. 0 - 1
  /// - a: the alpha value. 0 - 1.
  void setBackgroundColor(double r, double g, double b, double a) {
    _backgroundColor[0] = r;
    _backgroundColor[1] = g;
    _backgroundColor[2] = b;
    _backgroundColor[3] = a;
  }

  /// Renders the scene
  ///
  /// - [scene] the scene to render.
  /// - [camera] the scene camera.
  void render(Scene scene, Camera camera) {
    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * dpr).toInt() + 1, (height * dpr).toInt());

    // Clear the canvas. sets the canvas background color.
    // gl.clearColor(0, 0, 0, 1);
    gl.clearColor(_backgroundColor[0], _backgroundColor[1], _backgroundColor[2], _backgroundColor[3]);

    // Clear the canvas AND the depth buffer.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // enable CULL_FACE and DEPTH_TEST.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    // draw the objects.
    drawObjects(scene, camera);

    // ! super important.
    // ! never put this inside a loop because it takes some time
    // ! to update the texture.
    gl.finish();
    flgl.updateTexture();
  }

  void drawObjects(Scene scene, Camera camera) {
    for (var object in scene.children) {
      ProgramInfo programInfo = object.programInfo!;
      // Tell it to use our program (pair of shaders)
      // rememeber !!! for each model - object3d in the scene, some times is better
      // to use a seperate programe.
      gl.useProgram(programInfo.program);

      // Setup all the needed attributes.
      gl.bindVertexArray(object.vao);

      // Set the camera uniforms.
      Flutter3D.setUniforms(programInfo, camera.uniforms);

      // Set the object uniforms
      Flutter3D.setUniforms(programInfo, object.uniforms);

      // Set the object material related uniforms
      Flutter3D.setUniforms(programInfo, object.material.uniforms);

      if (object.geometry is EdgedBoxGeometry) {
        Flutter3D.drawBufferInfo(gl, object.geometry.bufferInfo, gl.LINES);
      } else {
        // calls gl.drawArrays or gl.drawElements
        Flutter3D.drawBufferInfo(gl, object.geometry.bufferInfo);
      }
    }
  }
}
