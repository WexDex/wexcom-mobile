import 'dart:math' as math;

/// Convert foreign major amount to default minor units using rate (1 foreign = rate default).
int convertMajorToDefaultMinor({
  required num majorAmount,
  required num rate,
  required int defaultFractionDigits,
}) {
  final product = majorAmount * rate;
  final scale = math.pow(10, defaultFractionDigits).toInt();
  return (product * scale).round();
}

/// Parse stored rate integer + scale to num (e.g. 255, scale 0 → 255).
num rateFromStored(int rateToDefault, int rateScale) {
  if (rateScale <= 0) return rateToDefault;
  return rateToDefault / math.pow(10, rateScale);
}

int rateToStored(num rate, {int scale = 0}) {
  if (scale <= 0) return rate.round();
  return (rate * math.pow(10, scale)).round();
}
