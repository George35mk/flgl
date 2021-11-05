import 'package:flgl/flutter3d/core/buffer_geometry.dart';
import 'cone_geometry.dart';

class CylinderGeometry extends BufferGeometry {
  /// Radius of cylinder.
  double radius;

  ///  Height of cylinder.
  double height;

  /// The number of subdivisions around the cylinder.
  int radialSubdivisions;

  /// The number of subdivisions down the cylinder.
  int verticalSubdivisions;

  /// Create top cap. Default = true.
  bool topCap;

  /// Create bottom cap. Default = true.
  bool bottomCap;

  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  CylinderGeometry(
    this.radius,
    this.height,
    this.radialSubdivisions,
    this.verticalSubdivisions, [
    this.topCap = true,
    this.bottomCap = true,
  ]) {
    var geometry = ConeGeometry(
      radius,
      radius,
      height,
      radialSubdivisions,
      verticalSubdivisions,
      topCap,
      bottomCap,
    );

    // Set index buffers and attributes.
    setIndex(geometry.indices);
    setAttribute('position', geometry.attributes['position']!);
    setAttribute('normal', geometry.attributes['normal']!);
    setAttribute('uv', geometry.attributes['uv']!);
  }
}
