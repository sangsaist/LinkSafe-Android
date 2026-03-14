import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants.dart';
import 'features/checker/check_result.dart';
import 'features/checker/pattern_checker.dart';
import 'features/warning/warning_screen.dart';
import 'features/history/history_screen.dart';
import 'core/history_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LinkSafeApp());
}

class LinkSafeApp extends StatefulWidget {
  const LinkSafeApp({super.key});

  @override
  State<LinkSafeApp> createState() => _LinkSafeAppState();
}

class _LinkSafeAppState extends State<LinkSafeApp> {
  static const MethodChannel _channel = MethodChannel(AppConstants.methodChannelName);
  final PatternChecker _checker = PatternChecker();
  final HistoryService _historyService = HistoryService();
  
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethodCall);
    _requestInitialUrl();
  }
  
  Future<void> _requestInitialUrl() async {
    try {
      final String? initialUrl = await _channel.invokeMethod('getInitialUrl');
      if (initialUrl != null && initialUrl.isNotEmpty) {
        _processUrl(initialUrl);
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get initial URL: '${e.message}'.");
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'checkUrl') {
      final String? url = call.arguments as String?;
      if (url != null && url.isNotEmpty) {
        _processUrl(url);
      }
    }
  }

  Future<void> _processUrl(String url) async {
    // Navigate back to home if already deep in navigation stack
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);

    // Show loading while checking
    showDialog(
      context: _navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.red),
      ),
    );

    final CheckResult result = _checker.check(url);
    await _historyService.saveEntry(url, result);
    
    // Dismiss loading
    Navigator.of(_navigatorKey.currentContext!).pop();

    if (result.isSuspicious) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => WarningScreen(checkResult: result),
        ),
      );
    } else {
      // Safe, silent open natively via intent bypass
      try {
        await _channel.invokeMethod('openSafeUrl', url);
        SystemNavigator.pop();
      } catch (e) {
        debugPrint('Error launching safe URL natively: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _ShieldHomeWidget(),
            HistoryScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blueGrey.shade800,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
             BottomNavigationBarItem(
               icon: Icon(Icons.shield),
               label: 'Shield',
             ),
             BottomNavigationBarItem(
               icon: Icon(Icons.access_time),
               label: 'History',
             ),
          ],
        ),
      ),
    );
  }
}

class _ShieldHomeWidget extends StatelessWidget {
  const _ShieldHomeWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(Icons.shield_rounded, size: 100, color: Colors.blueGrey.shade200),
           const SizedBox(height: 24),
           Text(
             'LinkSafe is Active',
             style: TextStyle(
               fontSize: 24,
               fontWeight: FontWeight.bold,
               color: Colors.blueGrey.shade800,
             ),
           ),
           const SizedBox(height: 12),
           Text(
             'Your device is being protected\nfrom malicious links.',
             textAlign: TextAlign.center,
             style: TextStyle(
               fontSize: 16,
               color: Colors.grey.shade600,
               height: 1.5,
             ),
           ),
        ],
      ),
    );
  }
}
