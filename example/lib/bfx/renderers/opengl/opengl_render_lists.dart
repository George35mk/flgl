import 'package:flgl_example/bfx/renderers/opengl/opengl_render_list.dart';
import 'package:weak_map/weak_map.dart';

import 'opengl_properties.dart';

class OpenGLRenderLists {
  WeakMap _lists = WeakMap();

  final OpenGLProperties properties;

  OpenGLRenderLists(this.properties);

  OpenGLRenderList get(scene, renderCallDepth) {
    OpenGLRenderList list;
    if (_lists.contains(scene) == false) {
      list = OpenGLRenderList(properties);
      _lists.add(key: scene, value: [list]);
    } else {
      if (renderCallDepth >= _lists.get(scene).length) {
        list = OpenGLRenderList(properties);
        _lists.get(scene)!.push(list);
      } else {
        list = _lists.get(scene)[renderCallDepth];
      }
    }

    return list;
  }

  dispose() {
    _lists = WeakMap();
  }
}
