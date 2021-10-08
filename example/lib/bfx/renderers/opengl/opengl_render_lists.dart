import 'package:weak_map/weak_map.dart';

import 'opengl_properties.dart';

class OpenGLRenderLists {
  WeakMap lists = WeakMap();

  OpenGLProperties properties;

  OpenGLRenderLists(this.properties);

  get() {}

  dispose() {}
}

class OpenGLRenderList {
  List renderItems = [];
  int renderItemsIndex = 0;

  List opaque = [];
  List transmissive = [];
  List transparent = [];

  final Map<String, int> defaultProgram = {'id': -1};

  OpenGLRenderList(properties);

  init() {}

  getNextRenderItem(object, geometry, material, groupOrder, z, group) {}

  push(object, geometry, material, groupOrder, z, group) {}

  unshift(object, geometry, material, groupOrder, z, group) {}

  sort(customOpaqueSort, customTransparentSort) {}

  finish() {}
}
