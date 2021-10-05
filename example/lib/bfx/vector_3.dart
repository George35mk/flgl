class Vector3 {
  double x;
  double y;
  double z;

  Vector3([this.x = 0, this.y = 0, this.z = 0]);

  // operator [](String i) => list[i]; // get
  operator []=(String i, double value) => {
        if (i == 'x')
          {x = value}
        else if (i == 'y')
          {y = value}
        else if (i == 'z')
          {z = value}
        else
          {throw 'Unknown operator'}
      }; // set
}
