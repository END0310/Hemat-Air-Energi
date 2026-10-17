import 'device_models.dart';
import 'meter_reading_model.dart';
import 'token_purchase_model.dart';

class PeriodConsumption {
  final MeterReading previousReading;
  final MeterReading currentReading;
  final List<TokenPurchase> tokensInPeriod;
  final double totalKwhTokensInPeriod;
  final double actualKwh;
  final int periodDays;
  final double dailyAverageKwh;
  final bool isNegative;
  final String formulaExplanation;

  const PeriodConsumption({
    required this.previousReading,
    required this.currentReading,
    required this.tokensInPeriod,
    required this.totalKwhTokensInPeriod,
    required this.actualKwh,
    required this.periodDays,
    required this.dailyAverageKwh,
    required this.isNegative,
    required this.formulaExplanation,
  });
}

class DailyChartPoint {
  final String dayLabel; // e.g., 'Sen', 'Sel'
  final DateTime date;
  final double kwh;
  final bool isToday;

  const DailyChartPoint({
    required this.dayLabel,
    required this.date,
    required this.kwh,
    this.isToday = false,
  });
}

class DeviceConsumptionRanking {
  final Device device;
  final double dailyKwh;
  final double monthlyKwh;
  final double monthlyCost;
  final double percentageOfTotal;
  final int rank;

  const DeviceConsumptionRanking({
    required this.device,
    required this.dailyKwh,
    required this.monthlyKwh,
    required this.monthlyCost,
    required this.percentageOfTotal,
    required this.rank,
  });
}
