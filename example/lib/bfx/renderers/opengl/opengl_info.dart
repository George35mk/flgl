import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class OpenGLInfo {
  OpenGLContextES gl;

  Map<String, dynamic> memory = {'geometries': 0, 'textures': 0};
  Map<String, dynamic> render = {'frame': 0, 'calls': 0, 'triangles': 0, 'points': 0, 'lines': 0};

  dynamic programs;
  bool autoReset = true;

  OpenGLInfo(this.gl);

  update(count, mode, instanceCount) {
    render['calls']++;

    switch (mode) {
      case 4: // gl.TRIANGLES
        render['triangles'] += instanceCount * (count / 3);
        break;

      case 1: // gl.LINES
        render['lines'] += instanceCount * (count / 2);
        break;

      case 3: // gl.LINE_STRIP
        render['lines'] += instanceCount * (count - 1);
        break;

      case 2: // gl.LINE_LOOP
        render['lines'] += instanceCount * count;
        break;

      case 0: // gl.POINTS
        render['points'] += instanceCount * count;
        break;

      default:
        print('THREE.WebGLInfo: Unknown draw mode: $mode');
        break;
    }
  }

  reset() {
    render['frame']++;
    render['calls'] = 0;
    render['triangles'] = 0;
    render['points'] = 0;
    render['lines'] = 0;
  }
}
