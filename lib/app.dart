import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reclip/core/ads/ad_manager.dart';
import 'package:reclip/core/config/app_config.dart';
import 'package:reclip/features/library/presentation/library_screen.dart';
import 'package:reclip/features/search/presentation/search_screen.dart';
import 'package:reclip/features/quick_save_toast/presentation/quick_save_toast.dart';
import 'package:reclip/features/item_detail/presentation/item_detail_screen.dart';
import 'package:reclip/features/share_intent/quick_save_service.dart';
import 'main.dart';

class ReclipApp extends ConsumerStatefulWidget {
  const ReclipApp({super.key});

  @override
  ConsumerState<ReclipApp> createState() => _ReclipAppState();
}

class _ReclipAppState extends ConsumerState<ReclipApp>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _saveCount = 0;
  static const int _interstitialInterval = 5; // show interstitial every N saves

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSaveCount();
    // Listen to share intents
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupShareIntentListener();
      _triggerEnrichment();
    });
  }

  Future<void> _loadSaveCount() async {
    final prefs = await SharedPreferences.getInstance();
    _saveCount = prefs.getInt('ad_save_counter') ?? 0;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerEnrichment();
    }
  }

  void _triggerEnrichment() {
    final orchestrator = ref.read(enrichmentOrchestratorProvider);
    orchestrator.processPendingQueue();
  }

  void _setupShareIntentListener() {
    final handler = ref.read(shareIntentHandlerProvider);
    handler.onSave.listen((saveResult) {
      if (mounted) {
        _onShareSaved(saveResult);
      }
    });
    // Handle cold start: emit any queued result from getInitialMedia
    handler.emitPendingIfAny();
  }

  void _onShareSaved(SaveResult result) {
    final item = result.item;
    if (item == null || !mounted) return;

    final db = ref.read(databaseProvider);
    final isNew = result.isNew;

    // Show toast briefly, then navigate to item detail
    QuickSaveToastOverlay.show(context, item, isNew, db);

    // Navigate to item detail after short delay (let toast appear first)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(item: item, db: db),
        ),
      );
    });

    // Trigger enrichment for new saves
    if (isNew) _triggerEnrichment();

    // Interstitial ad: count saves and show every N
    if (isNew && AppConfig.enableAds) {
      _incrementAndMaybeShowInterstitial();
    }
  }

  Future<void> _incrementAndMaybeShowInterstitial() async {
    _saveCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ad_save_counter', _saveCount);

    if (_saveCount >= _interstitialInterval) {
      _saveCount = 0;
      await prefs.setInt('ad_save_counter', 0);
      _showInterstitialAd();
    }
  }

  void _showInterstitialAd() {
    final adManager = ref.read(adManagerProvider);
    adManager.loadInterstitialAd(
      onLoaded: () {
        if (mounted) {
          adManager.showInterstitialAd();
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reclip',
      theme: ThemeData(
        colorSchemeSeed: Colors.black,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: PopScope(
        canPop: _currentIndex == 0, // Only allow exit from Library tab
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _currentIndex != 0) {
            // Switch to Library tab instead of exiting
            setState(() => _currentIndex = 0);
          }
        },
        child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            LibraryScreen(db: ref.watch(databaseProvider)),
            SearchScreen(db: ref.watch(databaseProvider)),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
          ],
        ),
      ),
    ),
    );
  }
}
