import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/bfx/renderers/shaders/shader_chunk.dart';

import '../../constants.dart';
import '../opengl_renderer.dart';
import 'opengl_shader.dart';
import 'opengl_uniforms.dart';

class OpenGLProgram {

  OpenGLRenderer renderer;
  dynamic bindingStates;

  late OpenGLContextES gl;
  dynamic defines;
  dynamic vertexShader;
  dynamic fragmentShader;

  dynamic shadowMapTypeDefine;
  dynamic envMapTypeDefine;
  dynamic envMapModeDefine;
  dynamic envMapBlendingDefine;

  dynamic gammaFactorDefine;
  dynamic customExtensions;
  dynamic customDefines;
  dynamic program;

  dynamic cachedUniforms;
  dynamic cachedAttributes;

  dynamic diagnostics;
  dynamic name;
  dynamic id;
  dynamic cacheKey;
  dynamic usedTimes;



  OpenGLProgram(this.renderer, cacheKey, parameters, this.bindingStates) {

    ShaderChunk shaderChunk = ShaderChunk();
    gl = renderer.getContext();

    defines = parameters.defines;

    vertexShader = parameters.vertexShader;
    fragmentShader = parameters.fragmentShader;

    shadowMapTypeDefine = generateShadowMapTypeDefine(parameters);
    envMapTypeDefine = generateEnvMapTypeDefine(parameters);
    envMapModeDefine = generateEnvMapModeDefine(parameters);
    envMapBlendingDefine = generateEnvMapBlendingDefine(parameters);

    gammaFactorDefine = (renderer.gammaFactor > 0) ? renderer.gammaFactor : 1.0;
    customExtensions = parameters.isWebGL2 ? '' : generateExtensions(parameters);
    customDefines = generateDefines(defines);
    program = gl.createProgram();

    var prefixVertex, prefixFragment;
    var versionString = parameters.glslVersion ? '#version ' + parameters.glslVersion + '\n' : '';

    if ( parameters.isRawShaderMaterial ) {

      prefixVertex = [

        customDefines

      ];

      if ( prefixVertex.length > 0 ) {

        prefixVertex += '\n';

      }

      prefixFragment = [
        customExtensions,
        customDefines
      ];

      if ( prefixFragment.length > 0 ) {

        prefixFragment += '\n';

      }

    } else {

      prefixVertex = [

        generatePrecision( parameters ),

        '#define SHADER_NAME ' + parameters.shaderName,

        customDefines,

        parameters.instancing ? '#define USE_INSTANCING' : '',
        parameters.instancingColor ? '#define USE_INSTANCING_COLOR' : '',

        parameters.supportsVertexTextures ? '#define VERTEX_TEXTURES' : '',

        '#define GAMMA_FACTOR ' + gammaFactorDefine,

        '#define MAX_BONES ' + parameters.maxBones,
        ( parameters.useFog && parameters.fog ) ? '#define USE_FOG' : '',
        ( parameters.useFog && parameters.fogExp2 ) ? '#define FOG_EXP2' : '',

        parameters.map ? '#define USE_MAP' : '',
        parameters.envMap ? '#define USE_ENVMAP' : '',
        parameters.envMap ? '#define ' + envMapModeDefine : '',
        parameters.lightMap ? '#define USE_LIGHTMAP' : '',
        parameters.aoMap ? '#define USE_AOMAP' : '',
        parameters.emissiveMap ? '#define USE_EMISSIVEMAP' : '',
        parameters.bumpMap ? '#define USE_BUMPMAP' : '',
        parameters.normalMap ? '#define USE_NORMALMAP' : '',
        ( parameters.normalMap && parameters.objectSpaceNormalMap ) ? '#define OBJECTSPACE_NORMALMAP' : '',
        ( parameters.normalMap && parameters.tangentSpaceNormalMap ) ? '#define TANGENTSPACE_NORMALMAP' : '',

        parameters.clearcoatMap ? '#define USE_CLEARCOATMAP' : '',
        parameters.clearcoatRoughnessMap ? '#define USE_CLEARCOAT_ROUGHNESSMAP' : '',
        parameters.clearcoatNormalMap ? '#define USE_CLEARCOAT_NORMALMAP' : '',

        parameters.displacementMap && parameters.supportsVertexTextures ? '#define USE_DISPLACEMENTMAP' : '',

        parameters.specularMap ? '#define USE_SPECULARMAP' : '',
        parameters.specularIntensityMap ? '#define USE_SPECULARINTENSITYMAP' : '',
        parameters.specularTintMap ? '#define USE_SPECULARTINTMAP' : '',

        parameters.roughnessMap ? '#define USE_ROUGHNESSMAP' : '',
        parameters.metalnessMap ? '#define USE_METALNESSMAP' : '',
        parameters.alphaMap ? '#define USE_ALPHAMAP' : '',

        parameters.transmission ? '#define USE_TRANSMISSION' : '',
        parameters.transmissionMap ? '#define USE_TRANSMISSIONMAP' : '',
        parameters.thicknessMap ? '#define USE_THICKNESSMAP' : '',

        parameters.vertexTangents ? '#define USE_TANGENT' : '',
        parameters.vertexColors ? '#define USE_COLOR' : '',
        parameters.vertexAlphas ? '#define USE_COLOR_ALPHA' : '',
        parameters.vertexUvs ? '#define USE_UV' : '',
        parameters.uvsVertexOnly ? '#define UVS_VERTEX_ONLY' : '',

        parameters.flatShading ? '#define FLAT_SHADED' : '',

        parameters.skinning ? '#define USE_SKINNING' : '',
        parameters.useVertexTexture ? '#define BONE_TEXTURE' : '',

        parameters.morphTargets ? '#define USE_MORPHTARGETS' : '',
        parameters.morphNormals && parameters.flatShading == false ? '#define USE_MORPHNORMALS' : '',
        ( parameters.morphTargets && parameters.isWebGL2 ) ? '#define MORPHTARGETS_TEXTURE' : '',
        ( parameters.morphTargets && parameters.isWebGL2 ) ? '#define MORPHTARGETS_COUNT ' + parameters.morphTargetsCount : '',
        parameters.doubleSided ? '#define DOUBLE_SIDED' : '',
        parameters.flipSided ? '#define FLIP_SIDED' : '',

        parameters.shadowMapEnabled ? '#define USE_SHADOWMAP' : '',
        parameters.shadowMapEnabled ? '#define ' + shadowMapTypeDefine : '',

        parameters.sizeAttenuation ? '#define USE_SIZEATTENUATION' : '',

        parameters.logarithmicDepthBuffer ? '#define USE_LOGDEPTHBUF' : '',
        ( parameters.logarithmicDepthBuffer && parameters.rendererExtensionFragDepth ) ? '#define USE_LOGDEPTHBUF_EXT' : '',

        'uniform mat4 modelMatrix;',
        'uniform mat4 modelViewMatrix;',
        'uniform mat4 projectionMatrix;',
        'uniform mat4 viewMatrix;',
        'uniform mat3 normalMatrix;',
        'uniform vec3 cameraPosition;',
        'uniform bool isOrthographic;',

        '#ifdef USE_INSTANCING',

        '	attribute mat4 instanceMatrix;',

        '#endif',

        '#ifdef USE_INSTANCING_COLOR',

        '	attribute vec3 instanceColor;',

        '#endif',

        'attribute vec3 position;',
        'attribute vec3 normal;',
        'attribute vec2 uv;',

        '#ifdef USE_TANGENT',

        '	attribute vec4 tangent;',

        '#endif',

        '#if defined( USE_COLOR_ALPHA )',

        '	attribute vec4 color;',

        '#elif defined( USE_COLOR )',

        '	attribute vec3 color;',

        '#endif',

        '#if ( defined( USE_MORPHTARGETS ) && ! defined( MORPHTARGETS_TEXTURE ) )',

        '	attribute vec3 morphTarget0;',
        '	attribute vec3 morphTarget1;',
        '	attribute vec3 morphTarget2;',
        '	attribute vec3 morphTarget3;',

        '	#ifdef USE_MORPHNORMALS',

        '		attribute vec3 morphNormal0;',
        '		attribute vec3 morphNormal1;',
        '		attribute vec3 morphNormal2;',
        '		attribute vec3 morphNormal3;',

        '	#else',

        '		attribute vec3 morphTarget4;',
        '		attribute vec3 morphTarget5;',
        '		attribute vec3 morphTarget6;',
        '		attribute vec3 morphTarget7;',

        '	#endif',

        '#endif',

        '#ifdef USE_SKINNING',

        '	attribute vec4 skinIndex;',
        '	attribute vec4 skinWeight;',

        '#endif',

        '\n'

      ];

      prefixFragment = [

        customExtensions,

        generatePrecision( parameters ),

        '#define SHADER_NAME ' + parameters.shaderName,

        customDefines,

        '#define GAMMA_FACTOR ' + gammaFactorDefine,

        ( parameters.useFog && parameters.fog ) ? '#define USE_FOG' : '',
        ( parameters.useFog && parameters.fogExp2 ) ? '#define FOG_EXP2' : '',

        parameters.map ? '#define USE_MAP' : '',
        parameters.matcap ? '#define USE_MATCAP' : '',
        parameters.envMap ? '#define USE_ENVMAP' : '',
        parameters.envMap ? '#define ' + envMapTypeDefine : '',
        parameters.envMap ? '#define ' + envMapModeDefine : '',
        parameters.envMap ? '#define ' + envMapBlendingDefine : '',
        parameters.lightMap ? '#define USE_LIGHTMAP' : '',
        parameters.aoMap ? '#define USE_AOMAP' : '',
        parameters.emissiveMap ? '#define USE_EMISSIVEMAP' : '',
        parameters.bumpMap ? '#define USE_BUMPMAP' : '',
        parameters.normalMap ? '#define USE_NORMALMAP' : '',
        ( parameters.normalMap && parameters.objectSpaceNormalMap ) ? '#define OBJECTSPACE_NORMALMAP' : '',
        ( parameters.normalMap && parameters.tangentSpaceNormalMap ) ? '#define TANGENTSPACE_NORMALMAP' : '',

        parameters.clearcoat ? '#define USE_CLEARCOAT' : '',
        parameters.clearcoatMap ? '#define USE_CLEARCOATMAP' : '',
        parameters.clearcoatRoughnessMap ? '#define USE_CLEARCOAT_ROUGHNESSMAP' : '',
        parameters.clearcoatNormalMap ? '#define USE_CLEARCOAT_NORMALMAP' : '',

        parameters.specularMap ? '#define USE_SPECULARMAP' : '',
        parameters.specularIntensityMap ? '#define USE_SPECULARINTENSITYMAP' : '',
        parameters.specularTintMap ? '#define USE_SPECULARTINTMAP' : '',
        parameters.roughnessMap ? '#define USE_ROUGHNESSMAP' : '',
        parameters.metalnessMap ? '#define USE_METALNESSMAP' : '',

        parameters.alphaMap ? '#define USE_ALPHAMAP' : '',
        parameters.alphaTest ? '#define USE_ALPHATEST' : '',

        parameters.sheen ? '#define USE_SHEEN' : '',

        parameters.transmission ? '#define USE_TRANSMISSION' : '',
        parameters.transmissionMap ? '#define USE_TRANSMISSIONMAP' : '',
        parameters.thicknessMap ? '#define USE_THICKNESSMAP' : '',

        parameters.vertexTangents ? '#define USE_TANGENT' : '',
        parameters.vertexColors || parameters.instancingColor ? '#define USE_COLOR' : '',
        parameters.vertexAlphas ? '#define USE_COLOR_ALPHA' : '',
        parameters.vertexUvs ? '#define USE_UV' : '',
        parameters.uvsVertexOnly ? '#define UVS_VERTEX_ONLY' : '',

        parameters.gradientMap ? '#define USE_GRADIENTMAP' : '',

        parameters.flatShading ? '#define FLAT_SHADED' : '',

        parameters.doubleSided ? '#define DOUBLE_SIDED' : '',
        parameters.flipSided ? '#define FLIP_SIDED' : '',

        parameters.shadowMapEnabled ? '#define USE_SHADOWMAP' : '',
        parameters.shadowMapEnabled ? '#define ' + shadowMapTypeDefine : '',

        parameters.premultipliedAlpha ? '#define PREMULTIPLIED_ALPHA' : '',

        parameters.physicallyCorrectLights ? '#define PHYSICALLY_CORRECT_LIGHTS' : '',

        parameters.logarithmicDepthBuffer ? '#define USE_LOGDEPTHBUF' : '',
        ( parameters.logarithmicDepthBuffer && parameters.rendererExtensionFragDepth ) ? '#define USE_LOGDEPTHBUF_EXT' : '',

        ( ( parameters.extensionShaderTextureLOD || parameters.envMap ) && parameters.rendererExtensionShaderTextureLod ) ? '#define TEXTURE_LOD_EXT' : '',

        'uniform mat4 viewMatrix;',
        'uniform vec3 cameraPosition;',
        'uniform bool isOrthographic;',

        ( parameters.toneMapping != NoToneMapping ) ? '#define TONE_MAPPING' : '',
        ( parameters.toneMapping != NoToneMapping ) ? shaderChunk.tonemapping_pars_fragment : '', // this code is required here because it is used by the toneMapping() function defined below
        ( parameters.toneMapping != NoToneMapping ) ? getToneMappingFunction( 'toneMapping', parameters.toneMapping ) : '',

        parameters.dithering ? '#define DITHERING' : '',
        parameters.format == RGBFormat ? '#define OPAQUE' : '',

        shaderChunk.encodings_pars_fragment, // this code is required here because it is used by the various encoding/decoding function defined below
        parameters.map ? getTexelDecodingFunction( 'mapTexelToLinear', parameters.mapEncoding ) : '',
        parameters.matcap ? getTexelDecodingFunction( 'matcapTexelToLinear', parameters.matcapEncoding ) : '',
        parameters.envMap ? getTexelDecodingFunction( 'envMapTexelToLinear', parameters.envMapEncoding ) : '',
        parameters.emissiveMap ? getTexelDecodingFunction( 'emissiveMapTexelToLinear', parameters.emissiveMapEncoding ) : '',
        parameters.specularTintMap ? getTexelDecodingFunction( 'specularTintMapTexelToLinear', parameters.specularTintMapEncoding ) : '',
        parameters.lightMap ? getTexelDecodingFunction( 'lightMapTexelToLinear', parameters.lightMapEncoding ) : '',
        getTexelEncodingFunction( 'linearToOutputTexel', parameters.outputEncoding ),

        parameters.depthPacking ? '#define DEPTH_PACKING ' + parameters.depthPacking : '',

        '\n'

      ];

    }

    vertexShader = resolveIncludes( vertexShader );
    vertexShader = replaceLightNums( vertexShader, parameters );
    vertexShader = replaceClippingPlaneNums( vertexShader, parameters );

    fragmentShader = resolveIncludes( fragmentShader );
    fragmentShader = replaceLightNums( fragmentShader, parameters );
    fragmentShader = replaceClippingPlaneNums( fragmentShader, parameters );

    vertexShader = unrollLoops( vertexShader );
    fragmentShader = unrollLoops( fragmentShader );

    if ( parameters.isWebGL2 && parameters.isRawShaderMaterial != true ) {

      // GLSL 3.0 conversion for built-in materials and ShaderMaterial

      versionString = '#version 300 es\n';

      prefixVertex = [
        'precision mediump sampler2DArray;',
        '#define attribute in',
        '#define varying out',
        '#define texture2D texture'
      ].join( '\n' ) + '\n' + prefixVertex;

      prefixFragment = [
        '#define varying in',
        ( parameters.glslVersion == GLSL3 ) ? '' : 'out highp vec4 pc_fragColor;',
        ( parameters.glslVersion == GLSL3 ) ? '' : '#define gl_FragColor pc_fragColor',
        '#define gl_FragDepthEXT gl_FragDepth',
        '#define texture2D texture',
        '#define textureCube texture',
        '#define texture2DProj textureProj',
        '#define texture2DLodEXT textureLod',
        '#define texture2DProjLodEXT textureProjLod',
        '#define textureCubeLodEXT textureLod',
        '#define texture2DGradEXT textureGrad',
        '#define texture2DProjGradEXT textureProjGrad',
        '#define textureCubeGradEXT textureGrad'
      ].join( '\n' ) + '\n' + prefixFragment;

    }

    final vertexGlsl = versionString + prefixVertex + vertexShader;
    final fragmentGlsl = versionString + prefixFragment + fragmentShader;

    // console.log( '*VERTEX*', vertexGlsl );
    // console.log( '*FRAGMENT*', fragmentGlsl );

    final glVertexShader = OpenGLShader( gl, gl.VERTEX_SHADER, vertexGlsl );
    final glFragmentShader = OpenGLShader( gl, gl.FRAGMENT_SHADER, fragmentGlsl );

    gl.attachShader( program, glVertexShader );
    gl.attachShader( program, glFragmentShader );

    // Force a particular attribute to index 0.

    if ( parameters.index0AttributeName != null ) {

      gl.bindAttribLocation( program, 0, parameters.index0AttributeName );

    } else if ( parameters.morphTargets == true ) {

      // programs with morphTargets displace position out of attribute 0
      gl.bindAttribLocation( program, 0, 'position' );

    }

	  gl.linkProgram( program );

    // check for link errors
    if ( renderer.debug['checkShaderErrors'] ) {

      final programLog = gl.getProgramInfoLog( program ).trim();
      final vertexLog = gl.getShaderInfoLog( glVertexShader ).trim();
      final fragmentLog = gl.getShaderInfoLog( glFragmentShader ).trim();

      var runnable = true;
      var haveDiagnostics = true;

      if ( gl.getProgramParameter( program, gl.LINK_STATUS ) == false ) {

        runnable = false;

        final vertexErrors = getShaderErrors( gl, glVertexShader, 'vertex' );
        final fragmentErrors = getShaderErrors( gl, glFragmentShader, 'fragment' );

        print(
          'THREE.WebGLProgram: Shader Error ' + gl.getError() + ' - ' +
          // 'VALIDATE_STATUS ' + gl.getProgramParameter( program, gl.VALIDATE_STATUS ) + '\n\n' + // disable for now
          'Program Info Log: ' + programLog + '\n' +
          vertexErrors + '\n' +
          fragmentErrors
        );

      } else if ( programLog != '' ) {

        print( 'THREE.WebGLProgram: Program Info Log: $programLog');

      } else if ( vertexLog == '' || fragmentLog == '' ) {

        haveDiagnostics = false;

      }

      if ( haveDiagnostics ) {

        diagnostics = {
          'runnable': runnable,
          'programLog': programLog,
          'vertexShader': {
            'log': vertexLog,
            'prefix': prefixVertex
          },
          'fragmentShader': {
            'log': fragmentLog,
            'prefix': prefixFragment
          }

        };

      }

    }

    // Clean up

    // Crashes in iOS9 and iOS10. #18402
    // gl.detachShader( program, glVertexShader );
    // gl.detachShader( program, glFragmentShader );

    gl.deleteShader( glVertexShader );
    gl.deleteShader( glFragmentShader );

    //
    this.name = parameters.shaderName;
    this.id = programIdCount++;
    this.cacheKey = cacheKey;
    this.usedTimes = 1;
    this.program = program;
    this.vertexShader = glVertexShader;
    this.fragmentShader = glFragmentShader;

  }

  // set up caching for uniform locations
  getUniforms () {
    cachedUniforms ??= OpenGLUniforms( gl, program );
    return cachedUniforms;
  }

  // set up caching for attribute locations
  getAttributes () {
    cachedAttributes ??= fetchAttributeLocations( gl, program );
    return cachedAttributes;
  }

  // free resource

  destroy () {
    bindingStates.releaseStatesOfProgram( this );
    gl.deleteProgram( program );
    program = null;
  }
}


var programIdCount = 0;

addLineNumbers( string ) {

	final lines = string.split( '\n' );

	for ( var i = 0; i < lines.length; i ++ ) {

		lines[ i ] = ( i + 1 ) + ': ' + lines[ i ];

	}

	return lines.join( '\n' );

}

getEncodingComponents( encoding ) {

	switch ( encoding ) {

		case LinearEncoding:
			return [ 'Linear', '( value )' ];
		case sRGBEncoding:
			return [ 'sRGB', '( value )' ];
		case RGBEEncoding:
			return [ 'RGBE', '( value )' ];
		case RGBM7Encoding:
			return [ 'RGBM', '( value, 7.0 )' ];
		case RGBM16Encoding:
			return [ 'RGBM', '( value, 16.0 )' ];
		case RGBDEncoding:
			return [ 'RGBD', '( value, 256.0 )' ];
		case GammaEncoding:
			return [ 'Gamma', '( value, float( GAMMA_FACTOR ) )' ];
		case LogLuvEncoding:
			return [ 'LogLuv', '( value )' ];
		default:
			print( 'THREE.WebGLProgram: Unsupported encoding: $encoding');
			return [ 'Linear', '( value )' ];

	}

}

getShaderErrors( gl, shader, type ) {

	final status = gl.getShaderParameter( shader, gl.COMPILE_STATUS );
	final errors = gl.getShaderInfoLog( shader ).trim();

	if ( status && errors == '' ) return '';

	// --enable-privileged-webgl-extension
	// console.log( '**' + type + '**', gl.getExtension( 'WEBGL_debug_shaders' ).getTranslatedShaderSource( shader ) );

	return type.toUpperCase() + '\n\n' + errors + '\n\n' + addLineNumbers( gl.getShaderSource( shader ) );

}

getTexelDecodingFunction( functionName, encoding ) {

	final components = getEncodingComponents( encoding );
	return 'vec4 ' + functionName + '( vec4 value ) { return ' + components[ 0 ] + 'ToLinear' + components[ 1 ] + '; }';

}

getTexelEncodingFunction( functionName, encoding ) {

	final components = getEncodingComponents( encoding );
	return 'vec4 ' + functionName + '( vec4 value ) { return LinearTo' + components[ 0 ] + components[ 1 ] + '; }';

}

getToneMappingFunction( functionName, toneMapping ) {

	var toneMappingName;

	switch ( toneMapping ) {

		case LinearToneMapping:
			toneMappingName = 'Linear';
			break;

		case ReinhardToneMapping:
			toneMappingName = 'Reinhard';
			break;

		case CineonToneMapping:
			toneMappingName = 'OptimizedCineon';
			break;

		case ACESFilmicToneMapping:
			toneMappingName = 'ACESFilmic';
			break;

		case CustomToneMapping:
			toneMappingName = 'Custom';
			break;

		default:
			print( 'THREE.WebGLProgram: Unsupported toneMapping: $toneMapping');
			toneMappingName = 'Linear';

	}

	return 'vec3 ' + functionName + '( vec3 color ) { return ' + toneMappingName + 'ToneMapping( color ); }';

}

generateExtensions( parameters ) {
	final chunks = [
		( parameters.extensionDerivatives || parameters.envMapCubeUV || parameters.bumpMap || parameters.tangentSpaceNormalMap || parameters.clearcoatNormalMap || parameters.flatShading || parameters.shaderID == 'physical' ) ? '#extension GL_OES_standard_derivatives : enable' : '',
		( parameters.extensionFragDepth || parameters.logarithmicDepthBuffer ) && parameters.rendererExtensionFragDepth ? '#extension GL_EXT_frag_depth : enable' : '',
		( parameters.extensionDrawBuffers && parameters.rendererExtensionDrawBuffers ) ? '#extension GL_EXT_draw_buffers : require' : '',
		( parameters.extensionShaderTextureLOD || parameters.envMap || parameters.transmission ) && parameters.rendererExtensionShaderTextureLod ? '#extension GL_EXT_shader_texture_lod : enable' : ''
	];
	return chunks;
}

generateDefines( defines ) {

	final chunks = [];

	for ( final name in defines ) {

		final value = defines[ name ];

		if ( value == false ) continue;

		chunks.add( '#define ' + name + ' ' + value );

	}

	return chunks.join( '\n' );

}

fetchAttributeLocations( gl, program ) {

	final attributes = {};

	final n = gl.getProgramParameter( program, gl.ACTIVE_ATTRIBUTES );

	for ( var i = 0; i < n; i ++ ) {

		final info = gl.getActiveAttrib( program, i );
		final name = info.name;

		var locationSize = 1;
		if ( info.type == gl.FLOAT_MAT2 ) locationSize = 2;
		if ( info.type == gl.FLOAT_MAT3 ) locationSize = 3;
		if ( info.type == gl.FLOAT_MAT4 ) locationSize = 4;

		// console.log( 'THREE.WebGLProgram: ACTIVE VERTEX ATTRIBUTE:', name, i );

		attributes[ name ] = {
			'type': info.type,
			'location': gl.getAttribLocation( program, name ),
			'locationSize': locationSize
		};

	}

	return attributes;

}

filterEmptyLine( string ) {
	return string != '';
}

replaceLightNums( String string, parameters ) {

	return string
		.replace( /NUM_DIR_LIGHTS/g, parameters.numDirLights )
		.replace( /NUM_SPOT_LIGHTS/g, parameters.numSpotLights )
		.replace( /NUM_RECT_AREA_LIGHTS/g, parameters.numRectAreaLights )
		.replace( /NUM_POINT_LIGHTS/g, parameters.numPointLights )
		.replace( /NUM_HEMI_LIGHTS/g, parameters.numHemiLights )
		.replace( /NUM_DIR_LIGHT_SHADOWS/g, parameters.numDirLightShadows )
		.replace( /NUM_SPOT_LIGHT_SHADOWS/g, parameters.numSpotLightShadows )
		.replace( /NUM_POINT_LIGHT_SHADOWS/g, parameters.numPointLightShadows );

}

replaceClippingPlaneNums( string, parameters ) {

	return string
		.replace( /NUM_CLIPPING_PLANES/g, parameters.numClippingPlanes )
		.replace( /UNION_CLIPPING_PLANES/g, ( parameters.numClippingPlanes - parameters.numClipIntersection ) );

}

// Resolve Includes

final includePattern = /^[ \t]*#include +<([\w\d./]+)>/gm;

resolveIncludes( String string ) {

	return string.replace( includePattern, includeReplacer );

}

includeReplacer( match, String include ) {
  ShaderChunk shaderChunk = ShaderChunk();
	final string = shaderChunk[ include ];

	if ( string == null ) {
		throw ( 'Can not resolve #include <' + include + '>' );
	}

	return resolveIncludes( string );
}

// Unroll Loops
// = new RegExp();
// https://stackoverflow.com/questions/49757486/how-to-use-regex-in-dart
final deprecatedUnrollLoopPattern = /#pragma unroll_loop[\s]+?for \( int i \= (\d+)\; i < (\d+)\; i \+\+ \) \{([\s\S]+?)(?=\})\}/g;
final unrollLoopPattern = /#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;

unrollLoops( string ) {

	return string
		.replace( unrollLoopPattern, loopReplacer )
		.replace( deprecatedUnrollLoopPattern, deprecatedLoopReplacer );

}

deprecatedLoopReplacer( match, start, end, snippet ) {

	print( 'WebGLProgram: #pragma unroll_loop shader syntax is deprecated. Please use #pragma unroll_loop_start syntax instead.' );
	return loopReplacer( match, start, end, snippet );

}

loopReplacer( match, start, end, snippet ) {

	var string = '';

	for ( var i = parseInt( start ); i < parseInt( end ); i ++ ) {

		string += snippet
			.replace( /\[\s*i\s*\]/g, '[ ' + i + ' ]' )
			.replace( /UNROLLED_LOOP_INDEX/g, i );

	}

	return string;

}

//

generatePrecision( parameters ) {

	var precisionstring = 'precision ' + parameters.precision + ' float;\nprecision ' + parameters.precision + ' int;';

	if ( parameters.precision == 'highp' ) {

		precisionstring += '\n#define HIGH_PRECISION';

	} else if ( parameters.precision == 'mediump' ) {

		precisionstring += '\n#define MEDIUM_PRECISION';

	} else if ( parameters.precision == 'lowp' ) {

		precisionstring += '\n#define LOW_PRECISION';

	}

	return precisionstring;

}

generateShadowMapTypeDefine( parameters ) {

	var shadowMapTypeDefine = 'SHADOWMAP_TYPE_BASIC';

	if ( parameters.shadowMapType == PCFShadowMap ) {

		shadowMapTypeDefine = 'SHADOWMAP_TYPE_PCF';

	} else if ( parameters.shadowMapType == PCFSoftShadowMap ) {

		shadowMapTypeDefine = 'SHADOWMAP_TYPE_PCF_SOFT';

	} else if ( parameters.shadowMapType == VSMShadowMap ) {

		shadowMapTypeDefine = 'SHADOWMAP_TYPE_VSM';

	}

	return shadowMapTypeDefine;

}

generateEnvMapTypeDefine( parameters ) {

	var envMapTypeDefine = 'ENVMAP_TYPE_CUBE';

	if ( parameters.envMap ) {

		switch ( parameters.envMapMode ) {

			case CubeReflectionMapping:
			case CubeRefractionMapping:
				envMapTypeDefine = 'ENVMAP_TYPE_CUBE';
				break;

			case CubeUVReflectionMapping:
			case CubeUVRefractionMapping:
				envMapTypeDefine = 'ENVMAP_TYPE_CUBE_UV';
				break;

		}

	}

	return envMapTypeDefine;

}

generateEnvMapModeDefine( parameters ) {

	var envMapModeDefine = 'ENVMAP_MODE_REFLECTION';

	if ( parameters.envMap ) {

		switch ( parameters.envMapMode ) {

			case CubeRefractionMapping:
			case CubeUVRefractionMapping:

				envMapModeDefine = 'ENVMAP_MODE_REFRACTION';
				break;

		}

	}

	return envMapModeDefine;

}

generateEnvMapBlendingDefine( parameters ) {

	var envMapBlendingDefine = 'ENVMAP_BLENDING_NONE';

	if ( parameters.envMap ) {

		switch ( parameters.combine ) {

			case MultiplyOperation:
				envMapBlendingDefine = 'ENVMAP_BLENDING_MULTIPLY';
				break;

			case MixOperation:
				envMapBlendingDefine = 'ENVMAP_BLENDING_MIX';
				break;

			case AddOperation:
				envMapBlendingDefine = 'ENVMAP_BLENDING_ADD';
				break;

		}

	}

	return envMapBlendingDefine;

}