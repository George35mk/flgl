import 'package:flgl_example/bfx/core/buffer_attribute.dart';
import 'package:flgl_example/bfx/core/buffer_geometry.dart';

import '../math/vector3.dart';

class BoxGeometry extends BufferGeometry {
  /// The box width
  double width;

  /// The box height
  double height;

  /// The box depth
  double depth;
  int widthSegments;
  int heightSegments;
  int depthSegments;

  BoxGeometry([
    this.width = 1,
    this.height = 1,
    this.depth = 1,
    this.widthSegments = 1,
    this.heightSegments = 1,
    this.depthSegments = 1,
  ]) {
    type = 'BoxGeometry';

    var scope = this; // segments

    widthSegments = widthSegments.floor();
    heightSegments = heightSegments.floor();
    depthSegments = depthSegments.floor(); // buffers

    List<int> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    int numberOfVertices = 0;
    int groupStart = 0; // build each side of the box geometry

    buildPlane(String u, String v, String w, int udir, int vdir, double width, double height, double depth, int gridX,
        int gridY, int materialIndex) {
      var segmentWidth = width / gridX;
      var segmentHeight = height / gridY;
      var widthHalf = width / 2;
      var heightHalf = height / 2;
      var depthHalf = depth / 2;
      var gridX1 = gridX + 1;
      var gridY1 = gridY + 1;
      int vertexCounter = 0;
      int groupCount = 0;
      var vector = Vector3(); // generate vertices, normals and uvs

      for (var iy = 0; iy < gridY1; iy++) {
        var y = iy * segmentHeight - heightHalf;

        for (var ix = 0; ix < gridX1; ix++) {
          var x = ix * segmentWidth - widthHalf; // set values to correct vector component

          vector[u] = x * udir;
          vector[v] = y * vdir;
          vector[w] = depthHalf; // now apply vector to vertex buffer

          // vertices.add(vector.x, vector.y, vector.z); // set values to correct vector component
          vertices.add(vector.x);
          vertices.add(vector.y);
          vertices.add(vector.z);

          vector[u] = 0;
          vector[v] = 0;
          vector[w] = depth > 0 ? 1 : -1; // now apply vector to normal buffer

          // normals.add(vector.x, vector.y, vector.z); // uvs
          normals.add(vector.x);
          normals.add(vector.y);
          normals.add(vector.z);

          uvs.add(ix / gridX);
          uvs.add(1 - iy / gridY); // counters

          vertexCounter += 1;
        }
      } // indices
      // 1. you need three indices to draw a single face
      // 2. a single segment consists of two faces
      // 3. so we need to generate six (2*3) indices per segment

      for (var iy = 0; iy < gridY; iy++) {
        for (var ix = 0; ix < gridX; ix++) {
          var a = numberOfVertices + ix + gridX1 * iy;
          var b = numberOfVertices + ix + gridX1 * (iy + 1);
          var c = numberOfVertices + (ix + 1) + gridX1 * (iy + 1);
          var d = numberOfVertices + (ix + 1) + gridX1 * iy; // faces

          // indices.add(a, b, d);
          // indices.add(b, c, d); // increase counter

          indices.add(a);
          indices.add(b);
          indices.add(d);
          //
          indices.add(b);
          indices.add(c);
          indices.add(d);

          groupCount += 6;
        }
      } // add a group to the geometry. this will ensure multi material support

      scope.addGroup(groupStart, groupCount, materialIndex); // calculate new start value for groups

      groupStart += groupCount; // update total number of vertices

      numberOfVertices += vertexCounter;
    }

    buildPlane('z', 'y', 'x', -1, -1, depth, height, width, depthSegments, heightSegments, 0); // px
    buildPlane('z', 'y', 'x', 1, -1, depth, height, -width, depthSegments, heightSegments, 1); // nx
    buildPlane('x', 'z', 'y', 1, 1, width, depth, height, widthSegments, depthSegments, 2); // py
    buildPlane('x', 'z', 'y', 1, -1, width, depth, -height, widthSegments, depthSegments, 3); // ny
    buildPlane('x', 'y', 'z', 1, -1, width, height, depth, widthSegments, heightSegments, 4); // pz
    buildPlane('x', 'y', 'z', -1, -1, width, height, -depth, widthSegments, heightSegments, 5); // nz

    // find the indices, vertices and normals and uv's
    // and the set the values
    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(vertices, 3));
    setAttribute('normal', Float32BufferAttribute(normals, 3));
    setAttribute('uv', Float32BufferAttribute(uvs, 2));
  }
}
