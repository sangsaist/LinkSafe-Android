class ParsedUrl {
  final String subdomain;
  final String platformDomain;
  final String fullHost;
  final String path;

  ParsedUrl({
    required this.subdomain,
    required this.platformDomain,
    required this.fullHost,
    required this.path,
  });
}

class UrlParser {
  static ParsedUrl parse(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      final host = uri.host.toLowerCase();
      final path = uri.path;

      final parts = host.split('.');
      String platformDomain = '';
      String subdomain = '';

      if (parts.length >= 2) {
        platformDomain = '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
        if (parts.length > 2) {
          subdomain = parts.sublist(0, parts.length - 2).join('.');
        }
      } else {
        platformDomain = host;
      }

      return ParsedUrl(
        subdomain: subdomain,
        platformDomain: platformDomain,
        fullHost: host,
        path: path,
      );
    } catch (e) {
      return ParsedUrl(
        subdomain: '',
        platformDomain: '',
        fullHost: '',
        path: '',
      );
    }
  }
}
