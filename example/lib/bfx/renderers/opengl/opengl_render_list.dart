import 'package:flgl_example/bfx/core/buffer_geometry.dart';
import 'package:flgl_example/bfx/core/object_3d.dart';
import 'package:flgl_example/bfx/renderers/opengl/opengl_properties.dart';

class OpenGLRenderList {
  final List _renderItems = [];
  int _renderItemsIndex = 0;

  List opaque = [];
  List transmissive = [];
  List transparent = [];

  final Map<String, int> _defaultProgram = {'id': -1};

  OpenGLProperties properties;

  OpenGLRenderList(this.properties);

  init() {
    _renderItemsIndex = 0;

    opaque.length = 0;
    transmissive.length = 0;
    transparent.length = 0;
  }

  _getNextRenderItem(Object3D object, BufferGeometry geometry, material, groupOrder, z, group) {
    Map renderItem = _renderItems[_renderItemsIndex];
    final materialProperties = properties.get(material);

    if (renderItem == null) {
      renderItem = {
        'id': object.id,
        'object': object,
        'geometry': geometry,
        'material': material,
        'program': materialProperties.program ?? _defaultProgram,
        'groupOrder': groupOrder,
        'renderOrder': object.renderOrder,
        'z': z,
        'group': group
      };

      _renderItems[_renderItemsIndex] = renderItem;
    } else {
      renderItem['id'] = object.id;
      renderItem['object'] = object;
      renderItem['geometry'] = geometry;
      renderItem['material'] = material;
      renderItem['program'] = materialProperties.program ?? _defaultProgram;
      renderItem['groupOrder'] = groupOrder;
      renderItem['renderOrder'] = object.renderOrder;
      renderItem['z'] = z;
      renderItem['group'] = group;
    }

    _renderItemsIndex++;

    return renderItem;
  }

  push(object, geometry, material, groupOrder, z, group) {
    var renderItem = _getNextRenderItem(object, geometry, material, groupOrder, z, group);

    if (material.transmission > 0.0) {
      transmissive.add(renderItem);
    } else if (material.transparent == true) {
      transparent.add(renderItem);
    } else {
      opaque.add(renderItem);
    }
  }

  unshift(object, geometry, material, groupOrder, z, group) {
    final renderItem = _getNextRenderItem(object, geometry, material, groupOrder, z, group);

    if (material.transmission > 0.0) {
      transmissive.insert(0, renderItem);
    } else if (material.transparent == true) {
      transparent.insert(0, renderItem);
    } else {
      opaque.insert(0, renderItem);
    }
  }

  sort(customOpaqueSort, customTransparentSort) {
    if (opaque.length > 1) opaque.sort(customOpaqueSort ?? painterSortStable);
    if (transmissive.length > 1) transmissive.sort(customTransparentSort ?? reversePainterSortStable);
    if (transparent.length > 1) transparent.sort(customTransparentSort ?? reversePainterSortStable);
  }

  finish() {
    // Clear references from inactive renderItems in the list

    for (var i = _renderItemsIndex, il = _renderItems.length; i < il; i++) {
      final renderItem = _renderItems[i];

      if (renderItem['id'] == null) break;

      renderItem['id'] = null;
      renderItem['object'] = null;
      renderItem['geometry'] = null;
      renderItem['material'] = null;
      renderItem['program'] = null;
      renderItem['group'] = null;
    }
  }
}

painterSortStable(a, b) {
  if (a.groupOrder != b.groupOrder) {
    return a.groupOrder - b.groupOrder;
  } else if (a.renderOrder != b.renderOrder) {
    return a.renderOrder - b.renderOrder;
  } else if (a.program != b.program) {
    return a.program.id - b.program.id;
  } else if (a.material.id != b.material.id) {
    return a.material.id - b.material.id;
  } else if (a.z != b.z) {
    return a.z - b.z;
  } else {
    return a.id - b.id;
  }
}

reversePainterSortStable(a, b) {
  if (a.groupOrder != b.groupOrder) {
    return a.groupOrder - b.groupOrder;
  } else if (a.renderOrder != b.renderOrder) {
    return a.renderOrder - b.renderOrder;
  } else if (a.z != b.z) {
    return b.z - a.z;
  } else {
    return a.id - b.id;
  }
}
