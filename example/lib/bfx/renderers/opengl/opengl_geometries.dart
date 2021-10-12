import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/bfx/core/buffer_attribute.dart';
import 'package:flgl_example/bfx/core/instanced_buffer_geometry.dart';
import 'package:flgl_example/bfx/renderers/opengl/opengl_attributes.dart';
import 'package:weak_map/weak_map.dart';

import 'opengl_binding_states.dart';
import 'opengl_info.dart';

class OpenGLGeometries {
  OpenGLContextES gl;
  OpenGLAttributes attributes;
  OpenGLInfo info;
  OpenGLBindingStates bindingStates;

  Map geometries = {};
  WeakMap wireframeAttributes = WeakMap();

  OpenGLGeometries(this.gl, this.attributes, this.info, this.bindingStates);

  onGeometryDispose(event) {
    final geometry = event.target;

    if (geometry.index != null) {
      attributes.remove(geometry.index);
    }

    for (const name in geometry.attributes) {
      attributes.remove(geometry.attributes[name]);
    }

    geometry.removeEventListener('dispose', onGeometryDispose);

    // delete geometries[ geometry.id ];
    geometries.remove(geometry.id);

    final attribute = wireframeAttributes.get(geometry);

    if (attribute) {
      attributes.remove(attribute);
      wireframeAttributes.remove(geometry);
    }

    bindingStates.releaseStatesOfGeometry(geometry);

    if (geometry is InstancedBufferGeometry == true) {
      // delete geometry._maxInstanceCount; // this is a bug, that prop dosnt exist in class.
    }

    //

    info.memory['geometries']--;
  }

  get(object, geometry) {
    if (geometries[geometry.id] == true) return geometry;

    geometry.addEventListener('dispose', onGeometryDispose);

    geometries[geometry.id] = true;

    info.memory['geometries']++;

    return geometry;
  }

  update(geometry) {
    final geometryAttributes = geometry.attributes;

    // Updating index buffer in VAO now. See WebGLBindingStates.

    for (const name in geometryAttributes) {
      attributes.update(geometryAttributes[name], gl.ARRAY_BUFFER);
    }

    // morph targets

    final morphAttributes = geometry.morphAttributes;

    for (const name in morphAttributes) {
      final array = morphAttributes[name];

      for (var i = 0, l = array.length; i < l; i++) {
        attributes.update(array[i], gl.ARRAY_BUFFER);
      }
    }
  }

  updateWireframeAttribute(geometry) {
    final indices = [];

    final geometryIndex = geometry.index;
    final geometryPosition = geometry.attributes.position;
    var version = 0;

    if (geometryIndex != null) {
      final array = geometryIndex.array;
      version = geometryIndex.version;

      for (var i = 0, l = array.length; i < l; i += 3) {
        final a = array[i + 0];
        final b = array[i + 1];
        final c = array[i + 2];

        // indices.push( a, b, b, c, c, a );
        indices.addAll([a, b, b, c, c, a]);
      }
    } else {
      final array = geometryPosition.array;
      version = geometryPosition.version;

      for (var i = 0, l = (array.length / 3) - 1; i < l; i += 3) {
        final a = i + 0;
        final b = i + 1;
        final c = i + 2;

        // indices.push( a, b, b, c, c, a );
        indices.addAll([a, b, b, c, c, a]);
      }
    }

    // var attribute = ( arrayMax( indices ) > 65535 ? Uint32BufferAttribute : Uint16BufferAttribute )( indices, 1 );
    var attribute;
    if (arrayMax(indices) > 65535) {
      attribute = Uint32BufferAttribute(indices, 1);
    } else {
      attribute = Uint16BufferAttribute(indices, 1);
    }

    attribute.version = version;

    // Updating index buffer in VAO now. See WebGLBindingStates

    //

    final previousAttribute = wireframeAttributes.get(geometry);

    if (previousAttribute) attributes.remove(previousAttribute);

    //

    // wireframeAttributes.set( geometry, attribute );
    wireframeAttributes.add(key: geometry, value: attribute);
  }

  getWireframeAttribute(geometry) {
    final currentAttribute = wireframeAttributes.get(geometry);

    if (currentAttribute) {
      final geometryIndex = geometry.index;

      if (geometryIndex != null) {
        // if the attribute is obsolete, create a new one

        if (currentAttribute.version < geometryIndex.version) {
          updateWireframeAttribute(geometry);
        }
      }
    } else {
      updateWireframeAttribute(geometry);
    }

    return wireframeAttributes.get(geometry);
  }
}

arrayMax(array) {
  if (array.length == 0) return -double.infinity;

  var max = array[0];

  for (var i = 1, l = array.length; i < l; ++i) {
    if (array[i] > max) max = array[i];
  }

  return max;
}
