import 'dart:math' as math;

import 'package:flgl_example/bfx/core/buffer_attribute.dart';

import 'math_utils.dart';

class Color {
  bool isColor = true;

  double r;
  double g;
  double b;

  Color([this.r = 0, this.g = 0, this.b = 0]) {
    if (g == null && b == null) {
      // r is THREE.Color, hex or string
      set(r);
    }

    setRGB(r, g, b);
  }

  Color set(dynamic value) {
    if (value && value.isColor) {
      copy(value);
    } else if (value is num) {
      setHex(value);
    } else if (value is String) {
      // setStyle( value );
    }

    return this;
  }

  setScalar(scalar) {
    r = scalar;
    g = scalar;
    b = scalar;

    return this;
  }

  setHex(hex) {
    hex = hex.floor();

    r = (hex >> 16 & 255) / 255;
    g = (hex >> 8 & 255) / 255;
    b = (hex & 255) / 255;

    return this;
  }

  setRGB(r, g, b) {
    this.r = r;
    this.g = g;
    this.b = b;

    return this;
  }

  setHSL(h, s, l) {
    // h,s,l ranges are in 0.0 - 1.0
    h = MathUtils.euclideanModulo(h, 1);
    s = MathUtils.clamp(s, 0, 1);
    l = MathUtils.clamp(l, 0, 1);

    if (s == 0) {
      r = g = b = l;
    } else {
      final p = l <= 0.5 ? l * (1 + s) : l + s - (l * s);
      final q = (2 * l) - p;

      r = hue2rgb(q, p, h + 1 / 3);
      g = hue2rgb(q, p, h);
      b = hue2rgb(q, p, h - 1 / 3);
    }

    return this;
  }

  // setStyle( style ) {

  // 	handleAlpha( string ) {

  // 		if ( string == null ) return;

  // 		if ( parseFloat( string ) < 1 ) {

  // 			print( 'THREE.Color: Alpha component of ' + style + ' will be ignored.' );

  // 		}

  // 	}

  // 	var m;

  // 	if ( m = /^((?:rgb|hsl)a?)\(([^\)]*)\)/.exec( style ) ) {

  // 		// rgb / hsl

  // 		var color;
  // 		final name = m[ 1 ];
  // 		final components = m[ 2 ];

  // 		switch ( name ) {

  // 			case 'rgb':
  // 			case 'rgba':

  // 				if ( color = /^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec( components ) ) {

  // 					// rgb(255,0,0) rgba(255,0,0,0.5)
  // 					this.r = math.min( 255, parseInt( color[ 1 ], 10 ) ) / 255;
  // 					this.g = math.min( 255, parseInt( color[ 2 ], 10 ) ) / 255;
  // 					this.b = math.min( 255, parseInt( color[ 3 ], 10 ) ) / 255;

  // 					handleAlpha( color[ 4 ] );

  // 					return this;

  // 				}

  // 				if ( color = /^\s*(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec( components ) ) {

  // 					// rgb(100%,0%,0%) rgba(100%,0%,0%,0.5)
  // 					this.r = math.min( 100, parseInt( color[ 1 ], 10 ) ) / 100;
  // 					this.g = math.min( 100, parseInt( color[ 2 ], 10 ) ) / 100;
  // 					this.b = math.min( 100, parseInt( color[ 3 ], 10 ) ) / 100;

  // 					handleAlpha( color[ 4 ] );

  // 					return this;

  // 				}

  // 				break;

  // 			case 'hsl':
  // 			case 'hsla':

  // 				if ( color = /^\s*(\d*\.?\d+)\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec( components ) ) {

  // 					// hsl(120,50%,50%) hsla(120,50%,50%,0.5)
  // 					const h = parseFloat( color[ 1 ] ) / 360;
  // 					const s = parseInt( color[ 2 ], 10 ) / 100;
  // 					const l = parseInt( color[ 3 ], 10 ) / 100;

  // 					handleAlpha( color[ 4 ] );

  // 					return setHSL( h, s, l );

  // 				}

  // 				break;

  // 		}

  // 	} else if ( m = /^\#([A-Fa-f\d]+)$/.exec( style ) ) {

  // 		// hex color

  // 		final hex = m[ 1 ];
  // 		final size = hex.length;

  // 		if ( size == 3 ) {

  // 			// #ff0
  // 			this.r = parseInt( hex.charAt( 0 ) + hex.charAt( 0 ), 16 ) / 255;
  // 			this.g = parseInt( hex.charAt( 1 ) + hex.charAt( 1 ), 16 ) / 255;
  // 			this.b = parseInt( hex.charAt( 2 ) + hex.charAt( 2 ), 16 ) / 255;

  // 			return this;

  // 		} else if ( size == 6 ) {

  // 			// #ff0000
  // 			this.r = parseInt( hex.charAt( 0 ) + hex.charAt( 1 ), 16 ) / 255;
  // 			this.g = parseInt( hex.charAt( 2 ) + hex.charAt( 3 ), 16 ) / 255;
  // 			this.b = parseInt( hex.charAt( 4 ) + hex.charAt( 5 ), 16 ) / 255;

  // 			return this;

  // 		}

  // 	}

  // 	if ( style && style.length > 0 ) {

  // 		return this.setColorName( style );

  // 	}

  // 	return this;

  // }

  setColorName(style) {
    // color keywords
    final hex = _colorKeywords[style.toLowerCase()];

    if (hex != null) {
      // red
      this.setHex(hex);
    } else {
      // unknown color
      print('THREE.Color: Unknown color ' + style);
    }

    return this;
  }

  Color clone() {
    return Color(r, g, b);
  }

  Color copy(Color color) {
    r = color.r;
    g = color.g;
    b = color.b;

    return this;
  }

  Color copyGammaToLinear(Color color, [double gammaFactor = 2.0]) {
    r = math.pow(color.r, gammaFactor).toDouble();
    g = math.pow(color.g, gammaFactor).toDouble();
    b = math.pow(color.b, gammaFactor).toDouble();

    return this;
  }

  Color copyLinearToGamma(Color color, [double gammaFactor = 2.0]) {
    final safeInverse = (gammaFactor > 0) ? (1.0 / gammaFactor) : 1.0;

    r = math.pow(color.r, safeInverse).toDouble();
    g = math.pow(color.g, safeInverse).toDouble();
    b = math.pow(color.b, safeInverse).toDouble();

    return this;
  }

  Color convertGammaToLinear(gammaFactor) {
    copyGammaToLinear(this, gammaFactor);

    return this;
  }

  Color convertLinearToGamma(gammaFactor) {
    copyLinearToGamma(this, gammaFactor);

    return this;
  }

  Color copySRGBToLinear(Color color) {
    r = SRGBToLinear(color.r);
    g = SRGBToLinear(color.g);
    b = SRGBToLinear(color.b);

    return this;
  }

  Color copyLinearToSRGB(Color color) {
    r = LinearToSRGB(color.r);
    g = LinearToSRGB(color.g);
    b = LinearToSRGB(color.b);

    return this;
  }

  Color convertSRGBToLinear() {
    copySRGBToLinear(this);

    return this;
  }

  Color convertLinearToSRGB() {
    copyLinearToSRGB(this);

    return this;
  }

  getHex() {
    return (r.toInt() * 255) << 16 ^ (g.toInt() * 255) << 8 ^ (b.toInt() * 255) << 0;
  }

  getHexString() {
    return ('000000' + getHex().toString(16)).substring(-6);
  }

  getHSL(Hsl target) {
    // h,s,l ranges are in 0.0 - 1.0

    final r = this.r;
    final g = this.g;
    final b = this.b;

    final max = math.max(math.max(r, g), b);
    final min = math.min(math.min(r, g), b);

    var hue, saturation;
    final lightness = (min + max) / 2.0;

    if (min == max) {
      hue = 0;
      saturation = 0;
    } else {
      final delta = max - min;

      saturation = lightness <= 0.5 ? delta / (max + min) : delta / (2 - max - min);

      // switch (max) {
      //   case r:
      //     hue = (g - b) / delta + (g < b ? 6 : 0);
      //     break;
      //   case g:
      //     hue = (b - r) / delta + 2;
      //     break;
      //   case b:
      //     hue = (r - g) / delta + 4;
      //     break;
      // }

      if (max == r) {
        hue = (g - b) / delta + (g < b ? 6 : 0);
      } else if (g == max) {
        hue = (b - r) / delta + 2;
      } else if (b == max) {
        hue = (r - g) / delta + 4;
      }

      hue /= 6;
    }

    target.h = hue;
    target.s = saturation;
    target.l = lightness;

    return target;
  }

  getStyle() {
    final r = (this.r * 255) ?? 0;
    final g = (this.g * 255) ?? 0;
    final b = (this.b * 255) ?? 0;

    return 'rgb($r, $g, $b)';
  }

  offsetHSL(int h, int s, int l) {
    getHSL(_hslA);

    _hslA.h += h;
    _hslA.s += s;
    _hslA.l += l;

    setHSL(_hslA.h, _hslA.s, _hslA.l);

    return this;
  }

  Color add(Color color) {
    r += color.r;
    g += color.g;
    b += color.b;

    return this;
  }

  Color addColors(Color color1, Color color2) {
    r = color1.r + color2.r;
    g = color1.g + color2.g;
    b = color1.b + color2.b;

    return this;
  }

  Color addScalar(int s) {
    r += s;
    g += s;
    b += s;

    return this;
  }

  Color sub(Color color) {
    r = math.max(0, r - color.r);
    g = math.max(0, g - color.g);
    b = math.max(0, b - color.b);

    return this;
  }

  Color multiply(Color color) {
    r *= color.r;
    g *= color.g;
    b *= color.b;

    return this;
  }

  Color multiplyScalar(int s) {
    r *= s;
    g *= s;
    b *= s;

    return this;
  }

  Color lerp(Color color, int alpha) {
    r += (color.r - r) * alpha;
    g += (color.g - g) * alpha;
    b += (color.b - b) * alpha;

    return this;
  }

  Color lerpColors(Color color1, Color color2, int alpha) {
    r = color1.r + (color2.r - color1.r) * alpha;
    g = color1.g + (color2.g - color1.g) * alpha;
    b = color1.b + (color2.b - color1.b) * alpha;

    return this;
  }

  Color lerpHSL(Color color, int alpha) {
    getHSL(_hslA);
    color.getHSL(_hslB);

    final h = MathUtils.lerp(_hslA.h, _hslB.h, alpha);
    final s = MathUtils.lerp(_hslA.s, _hslB.s, alpha);
    final l = MathUtils.lerp(_hslA.l, _hslB.l, alpha);

    setHSL(h, s, l);

    return this;
  }

  bool equals(Color c) {
    return (c.r == r) && (c.g == g) && (c.b == b);
  }

  Color fromArray(List<double> array, [offset = 0]) {
    r = array[offset];
    g = array[offset + 1];
    b = array[offset + 2];

    return this;
  }

  List<double> toArray([List<double> array = const [], offset = 0]) {
    array[offset] = r;
    array[offset + 1] = g;
    array[offset + 2] = b;

    return array;
  }

  fromBufferAttribute(BufferAttribute attribute, int index) {
    r = attribute.getX(index);
    g = attribute.getY(index);
    b = attribute.getZ(index);

    if (attribute.normalized == true) {
      // assuming Uint8Array

      r /= 255;
      g /= 255;
      b /= 255;
    }

    return this;
  }

  toJSON() {
    return getHex();
  }
}

const _colorKeywords = {
  'aliceblue': 0xF0F8FF,
  'antiquewhite': 0xFAEBD7,
  'aqua': 0x00FFFF,
  'aquamarine': 0x7FFFD4,
  'azure': 0xF0FFFF,
  'beige': 0xF5F5DC,
  'bisque': 0xFFE4C4,
  'black': 0x000000,
  'blanchedalmond': 0xFFEBCD,
  'blue': 0x0000FF,
  'blueviolet': 0x8A2BE2,
  'brown': 0xA52A2A,
  'burlywood': 0xDEB887,
  'cadetblue': 0x5F9EA0,
  'chartreuse': 0x7FFF00,
  'chocolate': 0xD2691E,
  'coral': 0xFF7F50,
  'cornflowerblue': 0x6495ED,
  'cornsilk': 0xFFF8DC,
  'crimson': 0xDC143C,
  'cyan': 0x00FFFF,
  'darkblue': 0x00008B,
  'darkcyan': 0x008B8B,
  'darkgoldenrod': 0xB8860B,
  'darkgray': 0xA9A9A9,
  'darkgreen': 0x006400,
  'darkgrey': 0xA9A9A9,
  'darkkhaki': 0xBDB76B,
  'darkmagenta': 0x8B008B,
  'darkolivegreen': 0x556B2F,
  'darkorange': 0xFF8C00,
  'darkorchid': 0x9932CC,
  'darkred': 0x8B0000,
  'darksalmon': 0xE9967A,
  'darkseagreen': 0x8FBC8F,
  'darkslateblue': 0x483D8B,
  'darkslategray': 0x2F4F4F,
  'darkslategrey': 0x2F4F4F,
  'darkturquoise': 0x00CED1,
  'darkviolet': 0x9400D3,
  'deeppink': 0xFF1493,
  'deepskyblue': 0x00BFFF,
  'dimgray': 0x696969,
  'dimgrey': 0x696969,
  'dodgerblue': 0x1E90FF,
  'firebrick': 0xB22222,
  'floralwhite': 0xFFFAF0,
  'forestgreen': 0x228B22,
  'fuchsia': 0xFF00FF,
  'gainsboro': 0xDCDCDC,
  'ghostwhite': 0xF8F8FF,
  'gold': 0xFFD700,
  'goldenrod': 0xDAA520,
  'gray': 0x808080,
  'green': 0x008000,
  'greenyellow': 0xADFF2F,
  'grey': 0x808080,
  'honeydew': 0xF0FFF0,
  'hotpink': 0xFF69B4,
  'indianred': 0xCD5C5C,
  'indigo': 0x4B0082,
  'ivory': 0xFFFFF0,
  'khaki': 0xF0E68C,
  'lavender': 0xE6E6FA,
  'lavenderblush': 0xFFF0F5,
  'lawngreen': 0x7CFC00,
  'lemonchiffon': 0xFFFACD,
  'lightblue': 0xADD8E6,
  'lightcoral': 0xF08080,
  'lightcyan': 0xE0FFFF,
  'lightgoldenrodyellow': 0xFAFAD2,
  'lightgray': 0xD3D3D3,
  'lightgreen': 0x90EE90,
  'lightgrey': 0xD3D3D3,
  'lightpink': 0xFFB6C1,
  'lightsalmon': 0xFFA07A,
  'lightseagreen': 0x20B2AA,
  'lightskyblue': 0x87CEFA,
  'lightslategray': 0x778899,
  'lightslategrey': 0x778899,
  'lightsteelblue': 0xB0C4DE,
  'lightyellow': 0xFFFFE0,
  'lime': 0x00FF00,
  'limegreen': 0x32CD32,
  'linen': 0xFAF0E6,
  'magenta': 0xFF00FF,
  'maroon': 0x800000,
  'mediumaquamarine': 0x66CDAA,
  'mediumblue': 0x0000CD,
  'mediumorchid': 0xBA55D3,
  'mediumpurple': 0x9370DB,
  'mediumseagreen': 0x3CB371,
  'mediumslateblue': 0x7B68EE,
  'mediumspringgreen': 0x00FA9A,
  'mediumturquoise': 0x48D1CC,
  'mediumvioletred': 0xC71585,
  'midnightblue': 0x191970,
  'mintcream': 0xF5FFFA,
  'mistyrose': 0xFFE4E1,
  'moccasin': 0xFFE4B5,
  'navajowhite': 0xFFDEAD,
  'navy': 0x000080,
  'oldlace': 0xFDF5E6,
  'olive': 0x808000,
  'olivedrab': 0x6B8E23,
  'orange': 0xFFA500,
  'orangered': 0xFF4500,
  'orchid': 0xDA70D6,
  'palegoldenrod': 0xEEE8AA,
  'palegreen': 0x98FB98,
  'paleturquoise': 0xAFEEEE,
  'palevioletred': 0xDB7093,
  'papayawhip': 0xFFEFD5,
  'peachpuff': 0xFFDAB9,
  'peru': 0xCD853F,
  'pink': 0xFFC0CB,
  'plum': 0xDDA0DD,
  'powderblue': 0xB0E0E6,
  'purple': 0x800080,
  'rebeccapurple': 0x663399,
  'red': 0xFF0000,
  'rosybrown': 0xBC8F8F,
  'royalblue': 0x4169E1,
  'saddlebrown': 0x8B4513,
  'salmon': 0xFA8072,
  'sandybrown': 0xF4A460,
  'seagreen': 0x2E8B57,
  'seashell': 0xFFF5EE,
  'sienna': 0xA0522D,
  'silver': 0xC0C0C0,
  'skyblue': 0x87CEEB,
  'slateblue': 0x6A5ACD,
  'slategray': 0x708090,
  'slategrey': 0x708090,
  'snow': 0xFFFAFA,
  'springgreen': 0x00FF7F,
  'steelblue': 0x4682B4,
  'tan': 0xD2B48C,
  'teal': 0x008080,
  'thistle': 0xD8BFD8,
  'tomato': 0xFF6347,
  'turquoise': 0x40E0D0,
  'violet': 0xEE82EE,
  'wheat': 0xF5DEB3,
  'white': 0xFFFFFF,
  'whitesmoke': 0xF5F5F5,
  'yellow': 0xFFFF00,
  'yellowgreen': 0x9ACD32
};

class Hsl {
  double h;
  double s;
  double l;

  Hsl(this.h, this.s, this.l);
}

// final _hslA = {'h': 0, 's': 0, 'l': 0};
// final _hslB = {'h': 0, 's': 0, 'l': 0};

final _hslA = Hsl(0, 0, 0);
final _hslB = Hsl(0, 0, 0);

SRGBToLinear(c) {
  return (c < 0.04045) ? c * 0.0773993808 : math.pow(c * 0.9478672986 + 0.0521327014, 2.4);
}

LinearToSRGB(c) {
  return (c < 0.0031308) ? c * 12.92 : 1.055 * (math.pow(c, 0.41666)) - 0.055;
}

hue2rgb(p, q, t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * 6 * (2 / 3 - t);
  return p;
}
