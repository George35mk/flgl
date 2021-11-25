import 'package:flgl/flutter3d/cameras/camera.dart';
import 'package:flgl/flutter3d/cameras/orthographic_camera.dart';
import 'package:flgl/flutter3d/cameras/perspective_camera.dart';
import 'package:flgl/flutter3d/math/m4.dart';
import 'dart:math' as math;

import 'package:flgl/flutter3d/math/math_utils.dart';
import 'package:flgl/flutter3d/math/matrix4.dart';
import 'package:flgl/flutter3d/math/vector3.dart';


class OrbitControls {

  /// the target camera.
  /// 
  ///  Can be OrthographicCamera or PerspectiveCamera
  dynamic camera;

  double camX = 0;
  double camY = 0;
  double camZ = 0;

  OrbitControls(this.camera);

  setActiveCamera(Camera camera) {
    this.camera = camera;
  }

  zoom(double scale,) {
    if (camera is OrthographicCamera) {
      camera.setOrthographic(scale * 8, -1.0, 1000.0);
    } else if (camera is PerspectiveCamera) {
      // zoom for perspective camera.
    } else {
      throw 'Unkown camera';
    }
  }

  /// add good descripption.
  /// I was planning to add orbit controls but I will this method here.
  orbit(double dx, double dy) {

    if (camera is OrthographicCamera) {
      double radious = 180;
      double speedFactor = 0.01;

      camX = (math.sin(dx * speedFactor) * radious);
      camY = (math.cos(dy * speedFactor) * 360);
      camZ = (math.cos(dx * speedFactor) * radious);

      camX = MathUtils.degToRad(camX);
      camY = MathUtils.degToRad(camY);
      camZ = MathUtils.degToRad(camZ);

      camera.setPosition(Vector3(-camX, -camY, camZ)); // rotate around y axis // Rotate on x, y and z axis works!!!
      
    } else if (camera is PerspectiveCamera) {
      print('Start PerspectiveCamera orbit, dx: $dx, dy: $dy');

      // glm::mat4 PivotPoint;
      // glm::mat4 Camera;
      // glm::mat4 View;
      // float RotationSPeed = 0.05f;

      // PivotPoint = glm::mat4(1.0f);
      // Camera = glm::mat4(1.0f);
      // View = glm::mat4(1.0f);
      // Camera = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f, -1.0f)) * Camera; //Offset it by some distance

      // do //fake game loop per frame
      // {
      //   if (OrbitRight) Camera = glm::rotate(glm::mat4(1.0f), RotationSpeed, glm::vec3(0.0f, 1.0f, 0.0f)) * Camera; 
      //   if (OrbitLeft) Camera = glm::rotate(glm::mat4(1.0f), -RotationSpeed, glm::vec3(0.0f, 1.0f, 0.0f)) * Camera; 
      //   if (PanRight) PivotPoint = glm::translate(glm::mat4(1.0f), glm::vec3(0.1f, 0.0f,0.0f)) * PivotPoint;
      //   if (PanLeft) PivotPoint = glm::translate(glm::mat4(1.0f), glm::vec3(-0.1f, 0.0f,0.0f)) * PivotPoint;
      //   if (ZoomIn) Camera = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f,0.1f)) * Camera;
      //   if (ZoomOut) Camera = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f,-0.1f)) * Camera;
      //   if (Forward) PivotPoint = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f,0.1f)) * PivotPoint;
      //   if (Back) PivotPoint = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f,-0.1f)) * PivotPoint;

      //   View = PivotPoint * Camera;
      //   View = glm::inverse(View); //More academic than actually necessary.
      // }while(GameRunning);



      // EXAMPLE 1: WORKS BUT IS NOT PERFECT
      const double radius = 500.0;
      double speedFactor = 0.01;
      camX = math.sin(dx * speedFactor) * radius;
      camY = math.cos(dy * speedFactor) * radius;
      camZ = math.cos(dx * speedFactor) * radius;

      camera.setPosition(Vector3(-camX, -camY, camZ));




      // EXAMPLE 2: I not working as I want.
      // double speedFactor = 0.001;

      // var mat = Matrix4();
      // var axisy = Vector3(0, 1, 0);
      // var xRad = MathUtils.degToRad(dx * speedFactor);

      // // print('xRad: $xRad');
      // // print('xRad to degree: ${MathUtils.radToDeg(xRad)}');

      // mat = mat.makeRotationAxis(axisy, xRad);
      // camera.viewMatrix = M4.multiply(camera.viewMatrix, mat.elements);

      
    } else {
      throw 'Unkown camera';
    }
  }
}