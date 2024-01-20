Duration hasPassed(String mongoTimeString) {
  return DateTime.now().difference(DateTime.parse(mongoTimeString));
}
