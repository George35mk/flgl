import 'package:flgl_example/bfx/cameras/camera.dart';
import 'package:flgl_example/bfx/cameras/orthographic_camera.dart';
import 'package:flgl_example/bfx/cameras/perspective_camera.dart';
import 'package:flgl_example/bfx/core/layers.dart';
import 'package:flgl_example/bfx/math/ray.dart';
import 'package:flgl_example/bfx/math/vector2.dart';
import 'package:flgl_example/bfx/math/vector3.dart';

import 'object_3d.dart';

class Raycaster {
  Vector3 origin = Vector3();
  Vector3 direction = Vector3();

  /// The far factor of the raycaster. This value indicates which objects can be
  /// discarded based on the distance. This value shouldn't be negative and should be
  /// larger than the near property.
  double near;

  /// The near factor of the raycaster. This value indicates which objects can be
  /// discarded based on the distance. This value shouldn't be negative and should
  /// be smaller than the far property.
  double far;

  late Ray ray;

  /// The camera to use when raycasting against view-dependent objects such as billboarded
  /// objects like Sprites. This field can be set manually or is set when calling
  /// "setFromCamera". Defaults to null.
  late Camera camera;

  /// Used by Raycaster to selectively ignore 3D objects when performing intersection tests.
  /// The following code example ensures that only 3D objects on layer 1 will be honored by
  /// the instance of Raycaster.
  Layers layers = Layers();

  /// An object with the following properties:
  ///
  /// ```
  /// {
  ///    Mesh: {},
  ///    Line: { threshold: 1 },
  ///    LOD: {},
  ///    Points: { threshold: 1 },
  ///    Sprite: {}
  ///  }
  /// ```
  ///
  /// Where threshold is the precision of the raycaster when intersecting objects, in world units.
  Map params = {
    'Mesh': {},
    'Line': {'threshold': 1},
    'LOD': {},
    'Points': {'threshold': 1},
    'Sprite': {}
  };

  Raycaster([Vector3? origin, Vector3? direction, this.near = 0, this.far = double.infinity]) {
    this.origin = origin ?? Vector3();
    this.direction = direction ?? Vector3();

    ray = Ray(origin, direction);
    // direction is assumed to be normalized (for accurate distance calculations)
  }

  /// Updates the ray with a new origin and direction. Please note that this
  /// method only copies the values from the arguments.
  ///
  /// - [origin] — The origin vector where the ray casts from.
  /// - [direction] — The normalized direction vector that gives direction to the ray.
  /// - direction is assumed to be normalized (for accurate distance calculations)
  void set(Vector3 origin, Vector3 direction) {
    ray.set(origin, direction);
  }

  /// Updates the ray with a new origin and direction.
  ///
  /// - [coords] — 2D coordinates of the mouse, in normalized device coordinates (NDC)---X and Y
  /// components should be between -1 and 1.
  /// - [camera] — camera from which the ray should originate
  void setFromCamera(Vector2 coords, Camera camera) {
    if (camera is PerspectiveCamera) {
      ray.origin.setFromMatrixPosition(camera.matrixWorld);
      ray.direction.set(coords.x, coords.y, 0.5).unproject(camera).sub(ray.origin).normalize();
      this.camera = camera;
    } else if (camera is OrthographicCamera) {
      ray.origin
          .set(coords.x, coords.y, (camera.near + camera.far) / (camera.near - camera.far))
          .unproject(camera); // set origin in plane of camera
      ray.direction.set(0, 0, -1).transformDirection(camera.matrixWorld);
      this.camera = camera;
    } else {
      print('THREE.Raycaster: Unsupported camera type: ${camera.type}');
    }
  }

  /// Checks all intersection between the ray and the object with or without the descendants.
  /// Intersections are returned sorted by distance, closest first. An array of intersections
  /// is returned...
  ///
  /// - [object] — The object to check for intersection with the ray.
  /// - [recursive] — If true, it also checks all descendants. Otherwise it only checks
  /// intersection with the object. Default is true.
  /// - [optionalTarget] — (optional) target to set the result. Otherwise a new Array is
  /// instantiated. If set, you must clear this array prior to each call (i.e., array.length = 0;).
  ///
  /// ```dart
  /// [ { distance, point, face, faceIndex, object }, ... ]
  /// ```
  ///
  /// - distance – distance between the origin of the ray and the intersection
  /// - point – point of intersection, in world coordinates
  /// - face – intersected face
  /// - faceIndex – index of the intersected face
  /// - object – the intersected object
  /// - uv - U,V coordinates at point of intersection
  /// - uv2 - Second set of U,V coordinates at point of intersection
  /// - instanceId – The index number of the instance where the ray intersects the InstancedMesh
  ///
  /// Raycaster delegates to the raycast method of the passed object, when evaluating whether
  /// the ray intersects the object or not. This allows meshes to respond differently to ray
  /// casting than lines and pointclouds.
  ///
  /// Note that for meshes, faces must be pointed towards the origin of the ray in order to
  /// be detected; intersections of the ray passing through the back of a face will not be
  /// detected. To raycast against both faces of an object, you'll want to set the material's
  /// side property to THREE.DoubleSide.
  intersectObject(Object3D object, [bool recursive = true, intersects = const []]) {
    _intersectObject(object, this, intersects, recursive);
    intersects.sort(ascSort);
    return intersects;
  }

  /// Checks all intersection between the ray and the objects with or without the descendants.
  /// Intersections are returned sorted by distance, closest first. Intersections are of the
  /// same form as those returned by .intersectObject.
  ///
  /// - [objects] — The objects to check for intersection with the ray.
  /// - [recursive] — If true, it also checks all descendants of the objects. Otherwise it
  /// only checks intersection with the objects. Default is true.
  /// - [optionalTarget] — (optional) target to set the result. Otherwise a new Array is
  /// instantiated. If set, you must clear this array prior to each call (i.e., array.length = 0;).
  intersectObjects(List<Object3D> objects, [bool recursive = true, intersects = const []]) {
    for (var i = 0, l = objects.length; i < l; i++) {
      _intersectObject(objects[i], this, intersects, recursive);
    }
    intersects.sort(ascSort);
    return intersects;
  }
}

ascSort(a, b) {
  return a.distance - b.distance;
}

_intersectObject(object, Raycaster raycaster, intersects, bool recursive) {
  if (object.layers.test(raycaster.layers)) {
    object.raycast(raycaster, intersects);
  }

  if (recursive == true) {
    final children = object.children;

    for (var i = 0, l = children.length; i < l; i++) {
      _intersectObject(children[i], raycaster, intersects, true);
    }
  }
}
