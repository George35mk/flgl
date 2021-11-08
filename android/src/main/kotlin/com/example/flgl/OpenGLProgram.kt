package com.example.flgl

import android.opengl.GLES30


//#version 300 es must be at first line
private val GLSL_VERTEX_SHADER = """#version 300 es
precision mediump float;

layout (location = 0) in vec4 Position;
layout (location = 1) in vec2 TextureCoords;
out vec2 TextureCoordsVarying;
uniform mat4 matrix;

void main () {
    gl_Position = matrix * Position;
    TextureCoordsVarying = TextureCoords;
}
"""

private val GLSL_FRAGMENT_SHADER = """#version 300 es
precision mediump float;

uniform sampler2D Texture0;
in vec2 TextureCoordsVarying;

out vec4 fragColor;

void main (void) { 
  vec4 mask0 = texture(Texture0, TextureCoordsVarying);
  vec4 color = vec4(mask0.rgb, mask0.a);
  fragColor = color;
}
"""


class OpenGLProgram {


    fun getProgram(): Int {
        return compileShaders(GLSL_VERTEX_SHADER, GLSL_FRAGMENT_SHADER);
    }

    fun compileShaders(vertex_shader: String, fragment_shader: String): Int {
        val vertexShader = this.compileShader(vertex_shader, GLES30.GL_VERTEX_SHADER)
        val fragmentShader = this.compileShader(fragment_shader, GLES30.GL_FRAGMENT_SHADER)

        val programHandle = GLES30.glCreateProgram()
        GLES30.glAttachShader(programHandle, vertexShader)
        GLES30.glAttachShader(programHandle, fragmentShader)
        GLES30.glLinkProgram(programHandle)

        var linkSuccess = IntArray(1);
        GLES30.glGetProgramiv(programHandle, GLES30.GL_LINK_STATUS, linkSuccess, 0)

        if (linkSuccess[0] == 0) {

            println(GLES30.glGetProgramInfoLog(programHandle));

            GLES30.glDeleteProgram(programHandle);
            throw Exception(" Linking of program failed. ")
        }

        return programHandle;
    }

    fun compileShader(shader: String, shaderType: Int): Int {
        return compileShaderCode(shader, shaderType);
    }

    fun compileShaderCode(shaderCode: String, shaderType: Int): Int {
        val shaderObjectId = GLES30.glCreateShader(shaderType)

        if (shaderObjectId == 0) {
            println("Could not create new shader.");
            return 0
        }

        GLES30.glShaderSource(shaderObjectId, shaderCode)
        GLES30.glCompileShader(shaderObjectId)

        val compileStatus = IntArray(1)
        GLES30.glGetShaderiv(shaderObjectId, GLES30.GL_COMPILE_STATUS, compileStatus, 0)

        println("Results of compiling source:" + GLES30.glGetShaderInfoLog(shaderObjectId))

        if (compileStatus[0] == 0) {

            println(GLES30.glGetProgramInfoLog(shaderObjectId));
            println("Compilation of shader failed.")

            GLES30.glDeleteShader(shaderObjectId)

            return 0
        }

        return shaderObjectId
    }

}