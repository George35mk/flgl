import 'package:flgl/flutter3d/core/neon_buffer_geometry.dart';
import 'neon_cone_geometry.dart';

class NeonCylinderGeometry extends NeonBufferGeometry {

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

  NeonCylinderGeometry({
    this.radius = 10.0,
    this.height = 50.0,
    this.radialSubdivisions = 10,
    this.verticalSubdivisions = 10,
    this.topCap = true,
    this.bottomCap = true,
  
  }) {
    NeonConeGeometry geometry = NeonConeGeometry(
      bottomRadius: radius,
      topRadius: radius,
      height: height,
      radialSubdivisions: radialSubdivisions,
      verticalSubdivisions: verticalSubdivisions,
      topCap: topCap,
      bottomCap: bottomCap,
    );

    vertices = geometry.vertices;
    indices = geometry.indices;
  }
  
}