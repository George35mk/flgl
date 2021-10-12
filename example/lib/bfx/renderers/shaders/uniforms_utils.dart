class UniformsUtils {
  static cloneUniforms(src) {
    final dst = {};

    for (const u in src) {
      dst[u] = {};

      for (const p in src[u]) {
        final property = src[u][p];

        if (property &&
            (property.isColor ||
                property.isMatrix3 ||
                property.isMatrix4 ||
                property.isVector2 ||
                property.isVector3 ||
                property.isVector4 ||
                property.isTexture ||
                property.isQuaternion)) {
          dst[u][p] = property.clone();
        } else if (Array.isArray(property)) {
          dst[u][p] = property.slice();
        } else {
          dst[u][p] = property;
        }
      }
    }

    return dst;
  }

  static mergeUniforms(uniforms) {
    const merged = {};

    for (var u = 0; u < uniforms.length; u++) {
      final tmp = cloneUniforms(uniforms[u]);

      for (const p in tmp) {
        merged[p] = tmp[p];
      }
    }

    return merged;
  }
}
