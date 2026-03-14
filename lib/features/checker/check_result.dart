enum RiskLevel { safe, warning, danger }

class CheckResult {
  final bool isSuspicious;
  final String reason;
  final RiskLevel riskLevel;
  final int riskScore;
  final String url;
  final String? platformDomain;
  final String? detectedBrand;

  CheckResult({
    required this.isSuspicious,
    required this.reason,
    required this.riskLevel,
    required this.riskScore,
    required this.url,
    this.platformDomain,
    this.detectedBrand,
  });
}
