class Layers {
  int mask = 0;
  Layers() {
    mask = 1 | 0;
  }

  set(channel) {
    mask = 1 << channel | 0;
  }

  enable(channel) {
    mask |= 1 << channel | 0;
  }

  enableAll() {
    mask = 0xffffffff | 0;
  }

  toggle(channel) {
    mask ^= 1 << channel | 0;
  }

  disable(channel) {
    mask &= ~(1 << channel | 0);
  }

  disableAll() {
    mask = 0;
  }

  test(Layers layers) {
    return (mask & layers.mask) != 0;
  }
}
