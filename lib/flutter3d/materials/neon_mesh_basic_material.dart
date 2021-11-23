import 'package:flgl/flutter3d/managers/texture_manager.dart';
import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/math/color.dart';

class NeonMeshBasicMaterial extends Material {
  /// The material color.
  Color? color;

  /// The texture map data as TextureInfo.
  TextureInfo? map; // the texture map.

  NeonMeshBasicMaterial({
    this.color,
    this.map,
  }) {
    color ??= Color(1, 1, 1, 1);

    // Initialize the mesh basic material shader source.

    if (map != null) {
      // load the texture shader source.
      String textureVS = """
        #version 300 es
        
        layout (location = 0) in vec4 a_Position;
        layout (location = 1) in vec4 a_Color;
        layout (location = 2) in vec3 a_Normal;
        layout (location = 3) in vec2 a_TexCoord;

        out vec2 v_TexCoord;
        out vec4 v_Color;
        out vec3 v_Normal;

        uniform mat4 u_Projection;
        uniform mat4 u_View;
        uniform mat4 u_Model;

        void main() {
          v_TexCoord = a_TexCoord;
          v_Color = a_Color;
          v_Normal = a_Normal;
          gl_Position = u_Projection * u_View * u_Model * a_Position;
        }
      """;

      String textureFS = """
        #version 300 es
        
        precision highp float;

        layout(location = 0) out vec4 color;

        in vec2 v_TexCoord;

        uniform vec4 u_Color;
        uniform sampler2D u_Texture;

        void main() {
          color = texture(u_Texture, v_TexCoord) * u_Color;
          // color = vec4(1);
        }
      """;
      shaderSource = {
        'vertexShader': textureVS,
        'fragmentShader': textureFS,
      };

    } else {

      String defaultVS = """
        #version 300 es
        
        layout (location = 0) in vec4 a_Position;
        layout (location = 1) in vec4 a_Color;
        layout (location = 2) in vec3 a_Normal;
        layout (location = 3) in vec2 a_TexCoord;
        
        // the projection matrix
        // the camera matrix
        // the model matrix

        uniform mat4 u_Projection;
        uniform mat4 u_View;
        uniform mat4 u_Model;

        out vec4 v_Color;
        out vec3 v_Normal;

        void main() {
          v_Color = a_Color;
          v_Normal = a_Normal;
          gl_Position = u_Projection * u_View * u_Model * a_Position;
        }
      """;

      String defaultFS = """
        #version 300 es
        
        precision highp float;

        layout(location = 0) out vec4 color;

        uniform vec4 u_Color;

        in vec4 v_Color;
        in vec3 v_Normal;

        void main() {
          color = u_Color;
        }
      """;

      shaderSource = {
        'vertexShader': defaultVS,
        'fragmentShader': defaultFS,
      };

    }

    // ignore: todo
    // TODO: If the user has map data then tou should change the shaderSource.
  }
}


