import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flutter3d/geometries/box_geometry.dart';
import 'package:flgl/flutter3d/geometries/cone_geometry.dart';
import 'package:flgl/flutter3d/geometries/cylinder_geometry.dart';
import 'package:flgl/flutter3d/geometries/edged_box_geometry.dart';
import 'package:flgl/flutter3d/geometries/plane_geometry.dart';
import 'package:flgl/flutter3d/geometries/sphere_geometry.dart';
import 'package:flgl/flutter3d/geometries/triangle_geometry.dart';
import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/materials/mesh_basic_material.dart';
import 'package:flgl/flutter3d/math/m4.dart';
import 'package:flgl/flutter3d/math/vector3.dart';
import 'package:flgl/flutter3d/shaders/box_shader.dart';
import 'package:flgl/flutter3d/shaders/generic_shader.dart';
import 'package:flgl/flutter3d/shaders/plane_shaders.dart';
import 'package:flgl/flutter3d/shaders/plane_with_textures.dart';
import 'package:flgl/flutter3d/shaders/sphere_shader.dart';
import 'package:flgl/flutter3d/shaders/triangle_shaders.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../flutter3d.dart';
import 'buffer_geometry.dart';

class Object3D {
  /// OpenGLES context.
  OpenGLContextES gl;

  /// The object geometry.
  BufferGeometry geometry;

  Material material;

  String name = '';

  /// The object3d program info.
  ProgramInfo? programInfo;

  /// The object VAO.
  dynamic vao; // is int

  /// The object uniforms.
  Map<String, dynamic> uniforms = {};

  /// The object position.
  Vector3 position = Vector3();

  /// The object rotation.
  Vector3 rotation = Vector3();

  /// The object scale.
  Vector3 scale = Vector3(1, 1, 1);

  /// The object matrix4 or u_world matrix.
  List<double> matrix = M4.identity();

  Object3D(this.gl, this.geometry, this.material) {
    if (geometry is TriangleGeometry) {
      setupTriangle(geometry);
    } else if (geometry is PlaneGeometry) {
      setupPlane(geometry, material);
    } else if (geometry is SphereGeometry) {
      setupSphere(geometry);
    } else if (geometry is BoxGeometry) {
      setupBox(geometry);
    } else if (geometry is ConeGeometry) {
      setupCone(geometry);
    } else if (geometry is CylinderGeometry) {
      setupCylinder(geometry);
    } else if (geometry is EdgedBoxGeometry) {
      setupEdgedBox(geometry);
    } else {
      print('Unkown geometry');
    }
  }

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
    gl.useProgram(0);
    gl.detachShader(programInfo!.program, programInfo!.vertexShader);
    gl.detachShader(programInfo!.program, programInfo!.fragmentShader);
    gl.deleteShader(programInfo!.vertexShader);
    gl.deleteShader(programInfo!.fragmentShader);
    gl.deleteProgram(programInfo!.program);
    print('Object3D.dispose called');
  }

  void setupGenericProgramInfo() {
    programInfo = Flutter3D.createProgramInfo(
      gl,
      genericShaders['vertexShader']!,
      genericShaders['fragmentShader']!,
    );
  }

  void setupGenericPlaneProgramInfo() {
    programInfo = Flutter3D.createProgramInfo(
      gl,
      planeShaders['vertexShader']!,
      planeShaders['fragmentShader']!,
    );
  }

  void setupPlaneWithTextureProgramInfo() {
    programInfo = Flutter3D.createProgramInfo(
      gl,
      planeWithTextureShaders['vertexShader']!,
      planeWithTextureShaders['fragmentShader']!,
    );
  }

  void setupMesh(BufferGeometry geometry, Material material) {
    if (geometry is PlaneGeometry) {
      if (material is MeshBasicMaterial) {
        if (material.map != null) {
          setupPlaneWithTextureProgramInfo();
        } else {
          setupGenericProgramInfo();
        }
      } else {
        setupGenericProgramInfo();
      }
    } else {
      // 1. Create a program based on geometry and material
      setupGenericProgramInfo();
    }

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // 3. Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);

    // if the material has map texture.
    if (material is MeshBasicMaterial) {
      if (material.map != null) {
        if (material.checkerboard) {
          setupCheckerboardTexture(material);
        } else {
          setupTexture(material);
        }
      }
    }
  }

  void setupTriangle(BufferGeometry geometry) {
    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(
      gl,
      triangleShaders['vertexShader']!,
      triangleShaders['fragmentShader']!,
    );

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // 3. Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }

  void setupPlane(BufferGeometry geometry, Material material) {
    // 1. init program based on geometry and material

    // planeWithTextureShaders
    if (material is MeshBasicMaterial) {
      if (material.map != null) {
        programInfo = Flutter3D.createProgramInfo(
          gl,
          planeWithTextureShaders['vertexShader']!,
          planeWithTextureShaders['fragmentShader']!,
        );
      } else {
        programInfo = Flutter3D.createProgramInfo(
          gl,
          planeShaders['vertexShader']!,
          planeShaders['fragmentShader']!,
        );
      }
    } else {
      programInfo = Flutter3D.createProgramInfo(
        gl,
        planeShaders['vertexShader']!,
        planeShaders['fragmentShader']!,
      );
    }

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // 3. Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);

    // if the material has map texture.
    if (material is MeshBasicMaterial) {
      if (material.map != null) {
        if (material.checkerboard) {
          setupCheckerboardTexture(material);
        } else {
          setupTexture(material);
        }
      }
    }
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

  void setupSphere(BufferGeometry geometry) {
    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(
      gl,
      sphereShaders['vertexShader']!,
      sphereShaders['fragmentShader']!,
    );

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }

  void setupBox(BufferGeometry geometry) {
    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(
      gl,
      boxShaders['vertexShader']!,
      boxShaders['fragmentShader']!,
    );

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }

  void setupCone(BufferGeometry geometry) {
    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(
      gl,
      boxShaders['vertexShader']!,
      boxShaders['fragmentShader']!,
    );

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }

  void setupCylinder(BufferGeometry geometry) {
    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(
      gl,
      boxShaders['vertexShader']!,
      boxShaders['fragmentShader']!,
    );

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }

  void setupEdgedBox(BufferGeometry geometry) {
    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(
      gl,
      boxShaders['vertexShader']!,
      boxShaders['fragmentShader']!,
    );

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }
}
