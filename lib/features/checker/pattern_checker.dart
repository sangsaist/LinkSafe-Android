import 'package:linksafe/core/constants.dart';
import 'check_result.dart';
import 'url_parser.dart';

class PatternChecker {
  CheckResult check(String urlString) {
    if (urlString.isEmpty) {
      return CheckResult(
        isSuspicious: false,
        reason: 'Empty URL',
        riskLevel: RiskLevel.safe,
        riskScore: 0,
        url: urlString,
      );
    }

    Uri? uri;
    try {
      uri = Uri.parse(urlString);
    } catch (e) {
      return CheckResult(
        isSuspicious: true,
        reason: 'Malformed URL format',
        riskLevel: RiskLevel.danger,
        riskScore: 100,
        url: urlString,
      );
    }

    int score = 0;
    List<String> reasons = [];
    String? matchedPlatform;
    String? matchedBrand;

    final parsed = UrlParser.parse(urlString);
    final host = parsed.fullHost;

    // 1. Check IP
    final ipv4RegExp = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$');
    if (ipv4RegExp.hasMatch(host)) {
      score += 90;
      reasons.add('IP address used instead of domain name (+90)');
    }

    // 2. HTTP impersonating sensitive brands
    if (uri.scheme == 'http') {
      for (var brand in AppConstants.trustedBrands) {
        if (host.contains(brand)) {
          score += 40;
          reasons.add('Insecure HTTP used on sensitive brand (+40)');
          break;
        }
      }
    }

    // 3. Known URL shorteners
    for (var shortener in AppConstants.urlShorteners) {
      if (host == shortener || host.endsWith('.$shortener')) {
        score += 60;
        reasons.add('Uses known URL shortener (+60)');
        break;
      }
    }

    // 4. Excessive subdomains (more than 4 dots in host)
    int dotCount = host.split('.').length - 1;
    if (dotCount > 4) {
      score += 50;
      reasons.add('Excessive subdomains (+50)');
    }

    // 5. Suspicious TLDs
    for (var tld in AppConstants.suspiciousTlds) {
      if (host.endsWith(tld)) {
        score += 70;
        reasons.add('Suspicious top-level domain $tld (+70)');
        break;
      }
    }

    // 6. Subdomain Analysis
    final sub = parsed.subdomain;
    int subdomainScore = 0;
    int keywordHits = 0;
    List<String> hitBrands = [];
    
    if (sub.isNotEmpty) {
      for (var kw in AppConstants.suspiciousKeywords) {
        if (sub.contains(kw)) {
          keywordHits++;
          hitBrands.add(kw);
        }
      }
      
      bool hasHyphenWithBrand = false;
      for (var kw in hitBrands) {
        if (sub.contains('$kw-') || sub.contains('-$kw')) {
          hasHyphenWithBrand = true;
          break;
        }
      }
      
      if (keywordHits >= 2) {
        subdomainScore = 90;
        reasons.add('Multiple sensitive keywords in subdomain (+$subdomainScore)');
      } else if (hasHyphenWithBrand) {
        subdomainScore = 70;
        reasons.add('Hyphenated sensitive name in subdomain (+$subdomainScore)');
      } else if (keywordHits == 1) {
        subdomainScore = 80;
        reasons.add('Sensitive keyword in subdomain (+$subdomainScore)');
      } else {
        subdomainScore = 0;
      }
    }
    
    score += subdomainScore;
    
    // 7. Platform Context
    bool isKnownPlatform = AppConstants.knownHostingPlatforms.contains(parsed.platformDomain);
    if (isKnownPlatform) {
       matchedPlatform = parsed.platformDomain;
       if (subdomainScore > 0) {
         matchedBrand = hitBrands.isNotEmpty ? hitBrands.first : null;
       }
       
       if (subdomainScore == 0) {
          // Final risk is safe
          score = 0; // Wipe out any other minimal scores since they verified a clean site on trusted platform
          reasons = ['Clean subdomain on known platform'];
       }
    } else {
       if (subdomainScore == 0 && parsed.platformDomain.isNotEmpty) {
          score += 20;
          reasons.add('Unknown external domain (+20)');
       }
    }

    RiskLevel finalLevel;
    bool suspicious = false;

    if (score <= 30) {
      finalLevel = RiskLevel.safe;
      suspicious = false;
    } else if (score <= 60) {
      finalLevel = RiskLevel.warning;
      suspicious = true;
    } else {
      finalLevel = RiskLevel.danger;
      suspicious = true;
    }

    if (score == 0 && reasons.isEmpty) {
      reasons.add('No immediate threats detected based on patterns');
    }

    return CheckResult(
      isSuspicious: suspicious,
      reason: reasons.join('\n'),
      riskLevel: finalLevel,
      riskScore: score,
      url: urlString,
      platformDomain: matchedPlatform,
      detectedBrand: matchedBrand,
    );
  }
}
