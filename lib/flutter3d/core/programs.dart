class Programs {
  Programs();

  /// setters the program attribute setters
  /// buffers the object bufferInfo
  ///
  /// 0:"buffer" -> Buffer
  /// 1:"numComponents" -> 3
  /// 2:"type" -> 5126
  /// 3:"normalize" -> false
  /// 4:"stride" -> 0
  /// 5:"offset" -> 0
  /// 6:"drawType" -> 35044
  static setAttributes(Map<String, dynamic> setters, Map<String, dynamic> buffers) {
    buffers.forEach((name, value) {
      var setter = setters['a_' + name];
      if (setter != null) {
        setter(buffers[name]);
      }
    });
    // for (var name in buffers) {
    //   var setter = setters[name];
    //   if (setter) {
    //     setter(buffers[name]);
    //   }
    // }
  }
}
