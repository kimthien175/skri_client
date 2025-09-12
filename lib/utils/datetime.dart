extension SubDate on DateTime {
  Duration operator -(DateTime other) => difference(other);
  Duration fromNow() => DateTime.now() - this;
}

extension DurationDivision on Duration {
  double operator /(Duration other) => inMicroseconds / other.inMicroseconds;
}
