extension SubDate on DateTime {
  Duration operator -(DateTime other) => difference(other);
}
