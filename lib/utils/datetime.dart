extension SubDate on DateTime {
  Duration operator -(DateTime other) => difference(other);
}

extension DurationDivision on Duration {
  double operator /(Duration other) => inMicroseconds / other.inMicroseconds;
}
