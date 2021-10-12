import 'buffer_geometry.dart';

class InstancedBufferGeometry extends BufferGeometry {
  bool isInstancedBufferGeometry = true;
  dynamic instanceCount = double.infinity;

  InstancedBufferGeometry() {
    type = 'InstancedBufferGeometry';
  }

  InstancedBufferGeometry copy(dynamic source) {
    super.copy(source);

    instanceCount = source.instanceCount;

    return this;
  }

  InstancedBufferGeometry clone() {
    return InstancedBufferGeometry().copy(this);
  }

  toJSON() {
    // const data = super.toJSON(this);

    // data.instanceCount = this.instanceCount;

    // data.isInstancedBufferGeometry = true;

    // return data;
  }
}
