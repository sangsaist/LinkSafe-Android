class AppConstants {
  static const String appName = 'LinkSafe';
  
  // Warning Screen Strings
  static const String warningTitle = 'Suspicious Link Detected!';
  static const String warningMessage = 'This link might be unsafe. It could lead to a fraudulent website, steal your personal information, or compromise your device. Please be safe and do not open it unless you are entirely sure.';
  static const String warningReasonPrefix = 'Reason: ';
  
  static const String actionDontOpen = 'Don\'t Open';
  static const String actionOpenAnyway = 'Open Anyway';
  
  // Config
  static const String methodChannelName = 'linksafe/url';
  
  // Suspicious Keywords
  static const List<String> suspiciousKeywords = [
    'sbi', 'hdfc', 'paytm', 'paypal', 'amazon', 'google', 'apple', 'microsoft', 
    'whatsapp', 'icici', 'bank', 'verify', 'secure', 'login', 'update', 'kyc', 'urgent', 'alert'
  ];

  // Known Hosting Platforms
  static const List<String> knownHostingPlatforms = [
    'netlify.app', 'vercel.app', 'github.io', 'pages.dev', 'firebaseapp.com', 'web.app', 'herokuapp.com'
  ];
  
  // Trusted Brands (for impersonation check)
  static const List<String> trustedBrands = [
    'paypal', 'amazon', 'sbi', 'hdfc', 'paytm', 'google', 'whatsapp', 'facebook', 'apple', 'microsoft'
  ];
  
  // Known Shorteners
  static const List<String> urlShorteners = [
    'bit.ly', 'tinyurl.com', 't.co', 'rb.gy', 'goo.gl', 'ow.ly', 'is.gd', 'buff.ly'
  ];
  
  // Suspicious TLDs
  static const List<String> suspiciousTlds = [
    '.xyz', '.tk', '.ml', '.ga', '.cf', '.top', '.click', '.loan', '.buzz', '.wang'
  ];
}
