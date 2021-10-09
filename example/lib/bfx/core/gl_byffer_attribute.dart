class GLBufferAttribute {
  /// A version number, incremented every time the needsUpdate property is set to true.
  int version = 0;

  bool isGLBufferAttribute = true;

  /// Must be a WebGLBuffer.
  dynamic buffer;

  /// type — One of WebGL Data Types.
  dynamic type;

  /// The number of values of the array that should be associated with a
  /// particular vertex. For instance, if this attribute is storing a 3-component
  /// vector (such as a position, normal, or color), then itemSize should be 3.
  int itemSize;

  /// 1, 2 or 4. The corresponding size (in bytes) for the given "type" param.
  /// - gl.FLOAT: 4
  /// - gl.UNSIGNED_SHORT: 2
  /// - gl.SHORT: 2
  /// - gl.UNSIGNED_INT: 4
  /// - gl.INT: 4
  /// - gl.BYTE: 1
  /// - gl.UNSIGNED_BYTE: 1
  int elementSize;

  ///  The expected number of vertices in VBO.
  int count;

  GLBufferAttribute(this.buffer, this.type, this.itemSize, this.elementSize, this.count);

  /// Default is false. Setting this to true increments version.
  set needsUpdate(value) {
    if (value == true) version++;
  }

  GLBufferAttribute setBuffer(buffer) {
    this.buffer = buffer;
    return this;
  }

  GLBufferAttribute setType(type, elementSize) {
    this.type = type;
    this.elementSize = elementSize;
    return this;
  }

  GLBufferAttribute setItemSize(itemSize) {
    this.itemSize = itemSize;
    return this;
  }

  GLBufferAttribute setCount(count) {
    this.count = count;
    return this;
  }
}
