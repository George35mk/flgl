import 'vector3.dart';
import 'dart:math' as math;

final _v0 = Vector3();
final _v1 = Vector3();
final _v2 = Vector3();
final _v3 = Vector3();

final _vab = Vector3();
final _vac = Vector3();
final _vbc = Vector3();
final _vap = Vector3();
final _vbp = Vector3();
final _vcp = Vector3();

class Triangle {
  Vector3 a = Vector3();
  Vector3 b = Vector3();
  Vector3 c = Vector3();

  Triangle([Vector3? _a, Vector3? _b, Vector3? _c]) {
    a = _a ?? Vector3();
    b = _b ?? Vector3();
    c = _c ?? Vector3();
  }

  static s_getNormal(a, b, c, target) {
    target.subVectors(c, b);
    _v0.subVectors(a, b);
    target.cross(_v0);

    final targetLengthSq = target.lengthSq();
    if (targetLengthSq > 0) {
      return target.multiplyScalar(1 / math.sqrt(targetLengthSq));
    }

    return target.set(0, 0, 0);
  }

  static s_getBarycoord(point, a, b, c, target) {
    _v0.subVectors(c, a);
    _v1.subVectors(b, a);
    _v2.subVectors(point, a);

    final dot00 = _v0.dot(_v0);
    final dot01 = _v0.dot(_v1);
    final dot02 = _v0.dot(_v2);
    final dot11 = _v1.dot(_v1);
    final dot12 = _v1.dot(_v2);

    final denom = (dot00 * dot11 - dot01 * dot01);

    // collinear or singular triangle
    if (denom == 0) {
      // arbitrary location outside of triangle?
      // not sure if this is the best idea, maybe should be returning undefined
      return target.set(-2, -1, -1);
    }

    final invDenom = 1 / denom;
    final u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    final v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // barycentric coordinates must always sum to 1
    return target.set(1 - u - v, v, u);
  }

  static s_containsPoint(point, a, b, c) {
    s_getBarycoord(point, a, b, c, _v3);

    return (_v3.x >= 0) && (_v3.y >= 0) && ((_v3.x + _v3.y) <= 1);
  }

  static s_getUV(point, p1, p2, p3, uv1, uv2, uv3, target) {
    s_getBarycoord(point, p1, p2, p3, _v3);

    target.set(0, 0);
    target.addScaledVector(uv1, _v3.x);
    target.addScaledVector(uv2, _v3.y);
    target.addScaledVector(uv3, _v3.z);

    return target;
  }

  static s_isFrontFacing(a, b, c, direction) {
    _v0.subVectors(c, b);
    _v1.subVectors(a, b);

    // strictly front facing
    return (_v0.cross(_v1).dot(direction) < 0) ? true : false;
  }

  set(a, b, c) {
    this.a.copy(a);
    this.b.copy(b);
    this.c.copy(c);

    return this;
  }

  setFromPointsAndIndices(points, i0, i1, i2) {
    a.copy(points[i0]);
    b.copy(points[i1]);
    c.copy(points[i2]);

    return this;
  }

  setFromAttributeAndIndices(attribute, i0, i1, i2) {
    a.fromBufferAttribute(attribute, i0);
    b.fromBufferAttribute(attribute, i1);
    c.fromBufferAttribute(attribute, i2);

    return this;
  }

  Triangle clone() {
    return Triangle().copy(this);
  }

  Triangle copy(Triangle triangle) {
    a.copy(triangle.a);
    b.copy(triangle.b);
    c.copy(triangle.c);

    return this;
  }

  getArea() {
    _v0.subVectors(c, b);
    _v1.subVectors(a, b);

    return _v0.cross(_v1).length() * 0.5;
  }

  getMidpoint(target) {
    return target.addVectors(a, b).add(c).multiplyScalar(1 / 3);
  }

  getNormal(target) {
    return s_getNormal(a, b, c, target);
  }

  getPlane(target) {
    return target.setFromCoplanarPoints(a, b, c);
  }

  getBarycoord(point, target) {
    return s_getBarycoord(point, a, b, c, target);
  }

  getUV(point, uv1, uv2, uv3, target) {
    return s_getUV(point, a, b, c, uv1, uv2, uv3, target);
  }

  containsPoint(point) {
    return s_containsPoint(point, a, b, c);
  }

  isFrontFacing(direction) {
    return s_isFrontFacing(a, b, c, direction);
  }

  intersectsBox(box) {
    return box.intersectsTriangle(this);
  }

  closestPointToPoint(p, target) {
    final a = this.a, b = this.b, c = this.c;
    var v, w;

    // algorithm thanks to Real-Time Collision Detection by Christer Ericson,
    // published by Morgan Kaufmann Publishers, (c) 2005 Elsevier Inc.,
    // under the accompanying license; see chapter 5.1.5 for detailed explanation.
    // basically, we're distinguishing which of the voronoi regions of the triangle
    // the point lies in with the minimum amount of redundant computation.

    _vab.subVectors(b, a);
    _vac.subVectors(c, a);
    _vap.subVectors(p, a);
    final d1 = _vab.dot(_vap);
    final d2 = _vac.dot(_vap);
    if (d1 <= 0 && d2 <= 0) {
      // vertex region of A; barycentric coords (1, 0, 0)
      return target.copy(a);
    }

    _vbp.subVectors(p, b);
    final d3 = _vab.dot(_vbp);
    final d4 = _vac.dot(_vbp);
    if (d3 >= 0 && d4 <= d3) {
      // vertex region of B; barycentric coords (0, 1, 0)
      return target.copy(b);
    }

    final vc = d1 * d4 - d3 * d2;
    if (vc <= 0 && d1 >= 0 && d3 <= 0) {
      v = d1 / (d1 - d3);
      // edge region of AB; barycentric coords (1-v, v, 0)
      return target.copy(a).addScaledVector(_vab, v);
    }

    _vcp.subVectors(p, c);
    final d5 = _vab.dot(_vcp);
    final d6 = _vac.dot(_vcp);
    if (d6 >= 0 && d5 <= d6) {
      // vertex region of C; barycentric coords (0, 0, 1)
      return target.copy(c);
    }

    final vb = d5 * d2 - d1 * d6;
    if (vb <= 0 && d2 >= 0 && d6 <= 0) {
      w = d2 / (d2 - d6);
      // edge region of AC; barycentric coords (1-w, 0, w)
      return target.copy(a).addScaledVector(_vac, w);
    }

    final va = d3 * d6 - d5 * d4;
    if (va <= 0 && (d4 - d3) >= 0 && (d5 - d6) >= 0) {
      _vbc.subVectors(c, b);
      w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
      // edge region of BC; barycentric coords (0, 1-w, w)
      return target.copy(b).addScaledVector(_vbc, w); // edge region of BC

    }

    // face region
    final denom = 1 / (va + vb + vc);
    // u = va * denom
    v = vb * denom;
    w = vc * denom;

    return target.copy(a).addScaledVector(_vab, v).addScaledVector(_vac, w);
  }

  equals(triangle) {
    return triangle.a.equals(a) && triangle.b.equals(b) && triangle.c.equals(c);
  }
}
