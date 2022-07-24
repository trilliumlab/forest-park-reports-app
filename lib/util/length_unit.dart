
class LengthUnit {
  static const LengthUnit Millimeter = LengthUnit(1000.0);
  static const LengthUnit Centimeter = LengthUnit(100.0);
  static const LengthUnit Meter = LengthUnit(1.0);
  static const LengthUnit Kilometer = LengthUnit(0.001);
  static const LengthUnit Mile = LengthUnit(0.0006213712);

  final double scaleFactor;

  const LengthUnit(this.scaleFactor);

  double to(final LengthUnit unit, final double value) {
    if (unit.scaleFactor == scaleFactor) {
      return value;
    }

    // Convert to primary unit.
    final primaryValue = value / scaleFactor;

    // Convert to destination unit.
    return primaryValue * unit.scaleFactor;
  }
}
