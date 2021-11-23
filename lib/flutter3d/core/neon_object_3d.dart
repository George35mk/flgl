import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/materials/mesh_basic_material.dart';
import 'package:flgl/flutter3d/math/m4.dart';
import 'package:flgl/flutter3d/math/vector3.dart';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';


class NeonObject3D {
  /// OpenGLES context.
  OpenGLContextES gl;

  /// The object geometry.
  NeonBufferGeometry geometry;

  /// The material
  Material material;

  late VertexArray vao;
  late VertexBuffer vb;
  late IndexBuffer ib;
  late Shader shader;

  /// The object name
  String name = '';

  /// The object uniforms.
  Map<String, dynamic> uniforms = {};

  /// The object position.
  Vector3 position = Vector3();

  /// The object rotation.
  Vector3 rotation = Vector3();

  /// The object scale.
  Vector3 scale = Vector3(1, 1, 1);

  /// The object - model matrix4 or u_world matrix.
  List<double> matrix = M4.identity();

  NeonObject3D(this.gl, this.geometry, this.material);

  /// Compose the object matrix.
  updateMatrix() {
    matrix = M4.translate(M4.identity(), position.x, position.y, position.z);
    matrix = M4.xRotate(matrix, rotation.x);
    matrix = M4.yRotate(matrix, rotation.y);
    matrix = M4.zRotate(matrix, rotation.z);
    matrix = M4.scale(matrix, scale.x, scale.y, scale.z);

    // update the uniforms.
    uniforms['u_world'] = matrix; // update the uniforms.
  }

  /// Set's the object position.
  setPosition(Vector3 v) {
    position.copy(v);
    updateMatrix();
  }

  /// Set's the object rotation in degrees.
  setRotation(Vector3 v) {
    rotation.x = MathUtils.degToRad(v.x);
    rotation.y = MathUtils.degToRad(v.y);
    rotation.z = MathUtils.degToRad(v.z);
    updateMatrix();
  }

  /// Set's the object scale.
  setScale(Vector3 v) {
    scale.copy(v);
    updateMatrix();
  }

  /// Call this method to:
  /// - detach the vertex and fragment shaders
  /// - delete the vertex and fragment shaders
  /// - delete the object program.
  void dispose() {
    // gl.useProgram(0);
    // gl.detachShader(programInfo!.program, programInfo!.vertexShader);
    // gl.detachShader(programInfo!.program, programInfo!.fragmentShader);
    // gl.deleteShader(programInfo!.vertexShader);
    // gl.deleteShader(programInfo!.fragmentShader);
    // gl.deleteProgram(programInfo!.program);
    print('Object3D.dispose called');
  }


  /// Creates a new texture and sets the material uniforms texture location.
  void setupTexture(MeshBasicMaterial material) {
    int width = material.mapWidth!;
    int height = material.mapHeigth!;

    int texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, material.map);

    gl.generateMipmap(gl.TEXTURE_2D);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    material.uniforms['u_texture'] = texture;
  }

  // make a 8x8 checkerboard texture
  void setupCheckerboardTexture(MeshBasicMaterial material) {
    // Uint8List imageData = Uint8List.fromList([
    //   0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
    //   0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
    //   0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
    //   0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
    //   0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
    //   0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
    //   0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
    //   0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
    // ]);
    int checkerboardTexture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, checkerboardTexture);
    gl.texImage2D(
      gl.TEXTURE_2D,
      0, // mip level
      gl.LUMINANCE, // internal format
      8, // width
      8, // height
      0, // border
      gl.LUMINANCE, // format
      gl.UNSIGNED_BYTE, // type
      // imageData
      material.map,
    );
    gl.generateMipmap(gl.TEXTURE_2D);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    material.uniforms['u_texture'] = checkerboardTexture;
  }



}
