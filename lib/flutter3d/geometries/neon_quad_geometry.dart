import 'package:flgl/flutter3d/core/neon_buffer_geometry.dart';

class NeonQuadGeometry extends NeonBufferGeometry {

  NeonQuadGeometry() {
    // Compute the indices, vertices, normals and uvs.

    // 1 component
    indices = [
      0, 1, 2,
      2, 3, 0
    ]; // 1
    
    // 3 components
    vertices = [
      -0.5, -0.5, 0.0, // 0
       0.5, -0.5, 0.0, // 1
       0.5,  0.5, 0.0, // 2
      -0.5,  0.5, 0.0, // 3
    ]; // 3

    // 3 components
    normals = [
      0.0, 1.0, 0.0, 
      0.0, 1.0, 0.0, 
      0.0, 1.0, 0.0
    ]; // 3

    // 2 components.
    uvs = [
      0.0, 0.0,
      1.0, 0.0,
      1.0, 1.0,
      0.0, 1.0,
    ]; // 2


    vertices = [
      // vertices(x, y, z)  Colors(r, g, b, a)    Normals(x, y, z)  UVs
      -0.5, -0.5, 0.0,      0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0,    0.0, 0.0, // 0 
       0.5, -0.5, 0.0,      0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0,    1.0, 0.0, // 1
       0.5,  0.5, 0.0,      0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0,    1.0, 1.0, // 2
      -0.5,  0.5, 0.0,      0.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0,    0.0, 1.0, // 3
    ];

  }
}
