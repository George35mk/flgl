import '../constants.dart';

class InterleavedBuffer {
  bool isInterleavedBuffer = true;
  List array;
  int stride;
  dynamic count;
  dynamic usage;
  dynamic updateRange;
  dynamic version;
  dynamic uuid;

  InterleavedBuffer(this.array, this.stride) {
    count = array != null ? array.length / stride : 0;
    usage = StaticDrawUsage;
    updateRange = {'offset': 0, 'count': -1};

    version = 0;

    // this.uuid = MathUtils.generateUUID();
  }

  set needsUpdate(bool value) {
    if (value == true) version++;
  }

  setUsage(value) {
    usage = value;

    return this;
  }

  copy(source) {
    array = source.array.constructor(source.array);
    count = source.count;
    stride = source.stride;
    usage = source.usage;

    return this;
  }

  copyAt(index1, attribute, index2) {
    index1 *= stride;
    index2 *= attribute.stride;

    for (var i = 0, l = stride; i < l; i++) {
      array[index1 + i] = attribute.array[index2 + i];
    }

    return this;
  }

  set(value, [offset = 0]) {
    array.set(value, offset);

    return this;
  }

  clone( data ) {

    data.arrayBuffers ??= {};

		if ( this.array.buffer._uuid == null ) {

			this.array.buffer._uuid = MathUtils.generateUUID();

		}

		if ( data.arrayBuffers[ this.array.buffer._uuid ] == undefined ) {

			data.arrayBuffers[ this.array.buffer._uuid ] = this.array.slice( 0 ).buffer;

		}

		const array = new this.array.constructor( data.arrayBuffers[ this.array.buffer._uuid ] );

		const ib = this.constructor( array, this.stride );
		ib.setUsage( this.usage );

		return ib;

	}

  onUpload( callback ) {

		this.onUploadCallback = callback;

		return this;

	}
}
