import 'package:weak_map/weak_map.dart';

class OpenGLProperties {
  WeakMap properties = WeakMap();

  OpenGLProperties();

  get(object) {
    var map = properties.get(object);

    // if (map == null) {
    //   map = {};
    //   properties.set(object, map);
    // }

    if (map == null) {
      map = {};
      var prop = properties.get(object);
      prop = map;
    }

    return map;
  }

  remove(object) {
    properties.remove(object);
  }

  update(object, key, value) {
    properties.get(object)[key] = value;
  }

  dispose() {
    /// maybe you nead to clear the old weakmap
    properties = WeakMap();
  }
}
