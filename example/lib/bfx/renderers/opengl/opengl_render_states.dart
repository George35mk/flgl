import 'package:weak_map/weak_map.dart';

import 'opengl_capabilities.dart';
import 'opengl_extensions.dart';
import 'opengl_lights.dart';

class OpenGLRenderState {
  OpenGLExtensions extensions;
  OpenGLCapabilities capabilities;

  late OpenGLLights lights;

  List lightsArray = [];
  List shadowsArray = [];

  Map<String, Object> state = {};

  OpenGLRenderState(this.extensions, this.capabilities) {
    lights = OpenGLLights(extensions, capabilities);

    state = {
      'lightsArray': lightsArray,
      'shadowsArray': shadowsArray,
      'lights': lights,
    };
  }

  init() {
    lightsArray.length = 0;
    shadowsArray.length = 0;
  }

  pushLight(light) {
    lightsArray.add(light);
  }

  pushShadow(shadowLight) {
    shadowsArray.add(shadowLight);
  }

  setupLights(physicallyCorrectLights) {
    lights.setup(lightsArray, physicallyCorrectLights);
  }

  setupLightsView(camera) {
    lights.setupView(lightsArray, camera);
  }
}

class OpenGLRenderStates {
  OpenGLExtensions extensions;
  OpenGLCapabilities capabilities;

  WeakMap _renderStates = WeakMap();

  OpenGLRenderStates(this.extensions, this.capabilities);

  get(scene, [renderCallDepth = 0]) {
    var renderState;

    // == null
    if (_renderStates.get(scene) == false) {
      renderState = OpenGLRenderState(extensions, capabilities);
      // renderStates.set(scene, [renderState]);
      _renderStates.add(key: scene, value: [renderState]);
    } else {
      if (renderCallDepth >= _renderStates.get(scene).length) {
        renderState = OpenGLRenderState(extensions, capabilities);
        _renderStates.get(scene).push(renderState);
      } else {
        renderState = _renderStates.get(scene)[renderCallDepth];
      }
    }

    return renderState;
  }

  dispose() {
    _renderStates = WeakMap();
  }
}
