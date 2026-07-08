int fastHash(String string) {
  var hash = 0x811c9dc5;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x01000193;
    hash ^= codeUnit & 0xFF;
    hash *= 0x01000193;
  }
  return hash & 0x7FFFFFFF;
}
