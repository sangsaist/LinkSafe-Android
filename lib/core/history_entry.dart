import 'package:linksafe/features/checker/check_result.dart';

class HistoryEntry {
  final String url;
  final DateTime timestamp;
  final RiskLevel riskLevel;
  final String reason;

  HistoryEntry({
    required this.url,
    required this.timestamp,
    required this.riskLevel,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'timestamp': timestamp.toIso8601String(),
      'riskLevel': riskLevel.toString(),
      'reason': reason,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    RiskLevel parseRiskLevel(String lvlStr) {
      if (lvlStr.contains('warning')) return RiskLevel.warning;
      if (lvlStr.contains('danger')) return RiskLevel.danger;
      return RiskLevel.safe;
    }

    return HistoryEntry(
      url: json['url'],
      timestamp: DateTime.parse(json['timestamp']),
      riskLevel: parseRiskLevel(json['riskLevel']),
      reason: json['reason'],
    );
  }
}
