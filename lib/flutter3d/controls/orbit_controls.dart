import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flgl/flutter3d/cameras/camera.dart';
import 'package:flgl/flutter3d/cameras/orthographic_camera.dart';
import 'package:flgl/flutter3d/cameras/perspective_camera.dart';
import 'package:flgl/flutter3d/math/vector3.dart';


/// ### OrbitControls
/// 
/// OrbitControls use the spherical coordinate system to
/// control the camera rotation around a target axis.
/// 
// ignore: todo
/// TODO: Add pan support.
/// 
/// You can find more resources here:
/// - https://en.wikipedia.org/wiki/Spherical_coordinate_system#Cartesian_coordinates.
/// - https://en.wikipedia.org/wiki/Polar_coordinate_system
class OrbitControls {

  /// The target camera.
  /// 
  ///  Can be OrthographicCamera or PerspectiveCamera
  dynamic camera;

  // orbit vars.
  Offset _offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  Offset _finalOffset = Offset.zero;

  // scale vars
  double _finalScale = 20;
  double _baseScale = 20;
  double _newScale = 1;
  double _previewsScale = 1;

  // phi and theta
  double phi = 0.001;
  double theta = 0.001;

  OrbitControls(this.camera) {
    _baseScale = camera.distanceToOrigin;
    _finalScale = camera.distanceToOrigin;
  }

  /// Sets the orbit control camera.
  setActiveCamera(Camera camera) {
    camera.distanceToOrigin = this.camera.distanceToOrigin;
    this.camera = camera;

    if (camera is OrthographicCamera) {
      camera.distanceToOrigin = _finalScale;
      camera.setOrthographic(_finalScale, -1.0, 1000.0);
    }

    // update the camera so we don't have the last rotation
    if (phi != 0 && theta != 0) {
      update();
    }
  }

  /// Use this method on orbit start.
  onOrbitStart(Offset focalPoint) {
    // print('On orbit start');
    _initialFocalPoint = focalPoint;
  }
  
  /// Orbits the camera around an orbit axis.
  /// 
  /// Constrains:
  /// 
  /// - r ≥ 0,
  /// - 0° ≤ θ ≤ 180° (π rad),
  /// - 0° ≤ φ < 360° (2π rad).
  onOrbit(Offset focalPoint) {
    // print('On orbit move');
    _sessionOffset = focalPoint - _initialFocalPoint;
    _finalOffset = _offset + _sessionOffset;

    double dx = _finalOffset.dx;
    double dy = _finalOffset.dy;

    phi = dy.abs() * math.pi / 360;
    theta = dx * math.pi / 180;

    if (phi != 0 && theta != 0) {
      update();
    }
  }

  /// On zoom stop
  onOrbitStop() {
    // print('On orbit stop');
    _offset += _sessionOffset;
  }

  /// On soom start.
  onZoomStart() {
    // print('Zoom start');
    _previewsScale = _newScale;
  }

  /// On zoom.
  onZoom(double scale) {
    _newScale = (_previewsScale * scale).clamp(0.5, 100.0);
    _finalScale = _newScale * _baseScale;

    if (camera is OrthographicCamera) {

      camera.distanceToOrigin = _finalScale;
      camera.setOrthographic(_finalScale, -1.0, 1000.0);

    } else if (camera is PerspectiveCamera) {

      camera.distanceToOrigin = _finalScale;

    } else {
      throw 'Unkown camera instance';
    }

    update();
  }

  /// Use this method on zoom stop.
  onZoomStop() {
    // print('Zoom stop');
  }

  /// Updates the X, Y, Z from phi and theta
  /// and sets the camera position vector.
  update() {
    double x = camera.distanceToOrigin * math.sin(phi) * math.cos(theta);
    double y = camera.distanceToOrigin * math.cos(phi);
    double z = camera.distanceToOrigin * math.sin(phi) * math.sin(theta);
    camera.setPosition(Vector3(x, y, z));
  }
}