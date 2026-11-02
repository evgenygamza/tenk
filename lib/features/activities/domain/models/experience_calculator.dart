/// Estimates prior experience using an average of 4.345 weeks per month.
class ExperienceCalculator {
  static const double weeksPerMonth = 4.345;
  static const int maxMonths = 1200;
  static const int maxHoursPerWeek = 168;
  static final int maxMinutes =
      (maxMonths * weeksPerMonth * maxHoursPerWeek * 60).round();

  /// Returns null for invalid or empty estimates; never truncates input limits.
  static int? estimateMinutes({
    required int years,
    required int months,
    required double hoursPerWeek,
  }) {
    if (years < 0 || years > 100 || months < 0 || months > 11) return null;
    final totalMonths = years * 12 + months;
    if (totalMonths <= 0 || totalMonths > maxMonths) return null;
    if (!hoursPerWeek.isFinite ||
        hoursPerWeek <= 0 ||
        hoursPerWeek > maxHoursPerWeek) {
      return null;
    }
    final minutes = (totalMonths * weeksPerMonth * hoursPerWeek * 60).round();
    return minutes > 0 ? minutes : null;
  }
}
