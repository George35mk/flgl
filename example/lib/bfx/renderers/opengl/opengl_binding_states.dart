import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'opengl_attributes.dart';
import 'opengl_capabilities.dart';
import 'opengl_extensions.dart';

class OpenGLBindingStates {
  OpenGLContextES gl;
  OpenGLExtensions extensions;
  OpenGLAttributes attributes;
  OpenGLCapabilities capabilities;

  late int maxVertexAttributes;
  dynamic extension;
  bool vaoAvailable = false;
  Map bindingStates = {};
  dynamic defaultState;
  dynamic currentState;

  OpenGLBindingStates(this.gl, this.extensions, this.attributes, this.capabilities) {
    maxVertexAttributes = gl.getParameter(gl.MAX_VERTEX_ATTRIBS);

    extension = capabilities.isWebGL2 ? null : extensions.get('OES_vertex_array_object');
    vaoAvailable = capabilities.isWebGL2 || extension != null;

    // bindingStates = {};

    defaultState = createBindingState(null);
    currentState = defaultState;
  }

  // public
  setup(object, material, program, geometry, index) {
    var updateBuffers = false;

    if (vaoAvailable) {
      final state = getBindingState(geometry, program, material);

      if (currentState != state) {
        currentState = state;
        bindVertexArrayObject(currentState.object);
      }

      updateBuffers = needsUpdate(geometry, index);

      if (updateBuffers) saveCache(geometry, index);
    } else {
      final wireframe = (material.wireframe == true);

      if (currentState.geometry != geometry.id ||
          currentState.program != program.id ||
          currentState.wireframe != wireframe) {
        currentState.geometry = geometry.id;
        currentState.program = program.id;
        currentState.wireframe = wireframe;

        updateBuffers = true;
      }
    }

    if (object.isInstancedMesh == true) {
      updateBuffers = true;
    }

    if (index != null) {
      attributes.update(index, gl.ELEMENT_ARRAY_BUFFER);
    }

    if (updateBuffers) {
      setupVertexAttributes(object, material, program, geometry);

      if (index != null) {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, attributes.get(index).buffer);
      }
    }
  }

  createVertexArrayObject() {
    if (capabilities.isWebGL2) return gl.createVertexArray();

    return extension.createVertexArrayOES();
  }

  bindVertexArrayObject(vao) {
    if (capabilities.isWebGL2) return gl.bindVertexArray(vao);

    return extension.bindVertexArrayOES(vao);
  }

  deleteVertexArrayObject(vao) {
    if (capabilities.isWebGL2) return gl.deleteVertexArray(vao);

    return extension.deleteVertexArrayOES(vao);
  }

  getBindingState(geometry, program, material) {
    final wireframe = (material.wireframe == true);

    var programMap = bindingStates[geometry.id];

    if (programMap == null) {
      programMap = {};
      bindingStates[geometry.id] = programMap;
    }

    var stateMap = programMap[program.id];

    if (stateMap == null) {
      stateMap = {};
      programMap[program.id] = stateMap;
    }

    var state = stateMap[wireframe];

    if (state == null) {
      state = createBindingState(createVertexArrayObject());
      stateMap[wireframe] = state;
    }

    return state;
  }

  createBindingState(vao) {
    final newAttributes = [];
    final enabledAttributes = [];
    final attributeDivisors = [];

    for (var i = 0; i < maxVertexAttributes; i++) {
      newAttributes[i] = 0;
      enabledAttributes[i] = 0;
      attributeDivisors[i] = 0;
    }

    return {
      // for backward compatibility on non-VAO support browser
      'geometry': null,
      'program': null,
      'wireframe': false,

      'newAttributes': newAttributes,
      'enabledAttributes': enabledAttributes,
      'attributeDivisors': attributeDivisors,
      'object': vao,
      'attributes': {},
      'index': null
    };
  }

  needsUpdate(geometry, index) {
    final cachedAttributes = currentState.attributes;
    final geometryAttributes = geometry.attributes;

    var attributesNum = 0;

    for (const key in geometryAttributes) {
      final cachedAttribute = cachedAttributes[key];
      final geometryAttribute = geometryAttributes[key];

      if (cachedAttribute == null) return true;

      if (cachedAttribute.attribute != geometryAttribute) return true;

      if (cachedAttribute.data != geometryAttribute.data) return true;

      attributesNum++;
    }

    if (currentState.attributesNum != attributesNum) return true;

    if (currentState.index != index) return true;

    return false;
  }

  saveCache(geometry, index) {
    final cache = {};
    final attributes = geometry.attributes;
    var attributesNum = 0;

    for (const key in attributes) {
      final attribute = attributes[key];

      final data = {};
      data['attribute'] = attribute;

      if (attribute.data) {
        data['data'] = attribute.data;
      }

      cache[key] = data;

      attributesNum++;
    }

    currentState.attributes = cache;
    currentState.attributesNum = attributesNum;

    currentState.index = index;
  }

  initAttributes() {
    final newAttributes = currentState.newAttributes;

    for (var i = 0, il = newAttributes.length; i < il; i++) {
      newAttributes[i] = 0;
    }
  }

  enableAttribute(attribute) {
    enableAttributeAndDivisor(attribute, 0);
  }

  enableAttributeAndDivisor(attribute, meshPerAttribute) {
    final newAttributes = currentState.newAttributes;
    final enabledAttributes = currentState.enabledAttributes;
    final attributeDivisors = currentState.attributeDivisors;

    newAttributes[attribute] = 1;

    if (enabledAttributes[attribute] == 0) {
      gl.enableVertexAttribArray(attribute);
      enabledAttributes[attribute] = 1;
    }

    if (attributeDivisors[attribute] != meshPerAttribute) {
      final extension = capabilities.isWebGL2 ? gl : extensions.get('ANGLE_instanced_arrays');

      extension[capabilities.isWebGL2 ? 'vertexAttribDivisor' : 'vertexAttribDivisorANGLE'](
          attribute, meshPerAttribute);
      attributeDivisors[attribute] = meshPerAttribute;
    }
  }

  disableUnusedAttributes() {
    final newAttributes = currentState.newAttributes;
    final enabledAttributes = currentState.enabledAttributes;

    for (var i = 0, il = enabledAttributes.length; i < il; i++) {
      if (enabledAttributes[i] != newAttributes[i]) {
        gl.disableVertexAttribArray(i);
        enabledAttributes[i] = 0;
      }
    }
  }

  vertexAttribPointer(index, size, type, normalized, stride, offset) {
    if (capabilities.isWebGL2 == true && (type == gl.INT || type == gl.UNSIGNED_INT)) {
      gl.vertexAttribIPointer(index, size, type, stride, offset);
    } else {
      gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
    }
  }

  setupVertexAttributes(object, material, program, geometry) {
    if (capabilities.isWebGL2 == false && (object.isInstancedMesh || geometry.isInstancedBufferGeometry)) {
      if (extensions.get('ANGLE_instanced_arrays') == null) return;
    }

    initAttributes();

    final geometryAttributes = geometry.attributes;

    final programAttributes = program.getAttributes();

    final materialDefaultAttributeValues = material.defaultAttributeValues;

    for (const name in programAttributes) {
      final programAttribute = programAttributes[name];

      if (programAttribute.location >= 0) {
        var geometryAttribute = geometryAttributes[name];

        if (geometryAttribute == null) {
          if (name == 'instanceMatrix' && object.instanceMatrix) geometryAttribute = object.instanceMatrix;
          if (name == 'instanceColor' && object.instanceColor) geometryAttribute = object.instanceColor;
        }

        if (geometryAttribute != null) {
          final normalized = geometryAttribute.normalized;
          final size = geometryAttribute.itemSize;

          final attribute = attributes.get(geometryAttribute);

          // TODO Attribute may not be available on context restore

          if (attribute == null) continue;

          final buffer = attribute.buffer;
          final type = attribute.type;
          final bytesPerElement = attribute.bytesPerElement;

          if (geometryAttribute.isInterleavedBufferAttribute) {
            final data = geometryAttribute.data;
            final stride = data.stride;
            final offset = geometryAttribute.offset;

            if (data && data.isInstancedInterleavedBuffer) {
              for (var i = 0; i < programAttribute.locationSize; i++) {
                enableAttributeAndDivisor(programAttribute.location + i, data.meshPerAttribute);
              }

              if (object.isInstancedMesh != true && geometry._maxInstanceCount == null) {
                geometry._maxInstanceCount = data.meshPerAttribute * data.count;
              }
            } else {
              for (var i = 0; i < programAttribute.locationSize; i++) {
                enableAttribute(programAttribute.location + i);
              }
            }

            gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

            for (var i = 0; i < programAttribute.locationSize; i++) {
              vertexAttribPointer(programAttribute.location + i, size / programAttribute.locationSize, type, normalized,
                  stride * bytesPerElement, (offset + (size / programAttribute.locationSize) * i) * bytesPerElement);
            }
          } else {
            if (geometryAttribute.isInstancedBufferAttribute) {
              for (var i = 0; i < programAttribute.locationSize; i++) {
                enableAttributeAndDivisor(programAttribute.location + i, geometryAttribute.meshPerAttribute);
              }

              if (object.isInstancedMesh != true && geometry._maxInstanceCount == null) {
                geometry._maxInstanceCount = geometryAttribute.meshPerAttribute * geometryAttribute.count;
              }
            } else {
              for (var i = 0; i < programAttribute.locationSize; i++) {
                enableAttribute(programAttribute.location + i);
              }
            }

            gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

            for (var i = 0; i < programAttribute.locationSize; i++) {
              vertexAttribPointer(programAttribute.location + i, size / programAttribute.locationSize, type, normalized,
                  size * bytesPerElement, (size / programAttribute.locationSize) * i * bytesPerElement);
            }
          }
        } else if (materialDefaultAttributeValues != null) {
          final value = materialDefaultAttributeValues[name];

          if (value != null) {
            switch (value.length) {
              case 2:
                gl.vertexAttrib2fv(programAttribute.location, value);
                break;

              case 3:
                gl.vertexAttrib3fv(programAttribute.location, value);
                break;

              case 4:
                gl.vertexAttrib4fv(programAttribute.location, value);
                break;

              default:
                gl.vertexAttrib1fv(programAttribute.location, value);
            }
          }
        }
      }
    }

    disableUnusedAttributes();
  }

  dispose() {
    reset();

    bindingStates.forEach((geometryId, value) {
      final programMap = bindingStates[geometryId];

      for (const programId in programMap) {
        final stateMap = programMap[programId];

        for (const wireframe in stateMap) {
          deleteVertexArrayObject(stateMap[wireframe].object);

          // delete stateMap[ wireframe ];
          stateMap.remove(wireframe);
        }

        // delete programMap[ programId ];
        programMap.remove(programId);
      }

      // delete bindingStates[ geometryId ];
      bindingStates.remove(geometryId);
    });
  }

  releaseStatesOfGeometry(geometry) {
    if (bindingStates[geometry.id] == null) return;

    final programMap = bindingStates[geometry.id];

    for (const programId in programMap) {
      final stateMap = programMap[programId];

      for (const wireframe in stateMap) {
        deleteVertexArrayObject(stateMap[wireframe].object);

        // delete stateMap[ wireframe ];
        stateMap.remove(wireframe);
      }

      // delete programMap[ programId ];
      programMap.remove(programId);
    }

    // delete bindingStates[ geometry.id ];
    bindingStates.remove(geometry.id);
  }

  releaseStatesOfProgram(program) {
    bindingStates.forEach((geometryId, value) {
      final programMap = bindingStates[geometryId];

      // check thus lile
      // if (programMap[program.id] == null) continue;

      final stateMap = programMap[program.id];

      for (const wireframe in stateMap) {
        deleteVertexArrayObject(stateMap[wireframe].object);

        // delete stateMap[ wireframe ];
        stateMap.remove(wireframe);
      }

      // delete programMap[ program.id ];
      programMap.remove(program.id);
    });
  }

  reset() {
    resetDefaultState();

    if (currentState == defaultState) return;

    currentState = defaultState;
    bindVertexArrayObject(currentState.object);
  }

  resetDefaultState() {
    defaultState.geometry = null;
    defaultState.program = null;
    defaultState.wireframe = false;
  }
}
