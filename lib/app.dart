import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclip/features/library/presentation/library_screen.dart';
import 'package:reclip/features/search/presentation/search_screen.dart';
import 'package:reclip/features/quick_save_toast/presentation/quick_save_toast.dart';
import 'main.dart';

class ReclipApp extends ConsumerStatefulWidget {
  const ReclipApp({super.key});

  @override
  ConsumerState<ReclipApp> createState() => _ReclipAppState();
}

class _ReclipAppState extends ConsumerState<ReclipApp>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen to share intents
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupShareIntentListener();
      _triggerEnrichment();
    });
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
    handler.onShare.listen((url) {
      if (mounted) {
        _showQuickSaveToast(url);
      }
    });
  }

  void _showQuickSaveToast(String url) async {
    final db = ref.read(databaseProvider);
    final canonical = _canonicalizeUrl(url);
    final item = await (db.select(db.savedItems)
          ..where((t) => t.canonicalUrl.equals(canonical)))
        .getSingleOrNull();
    if (item != null && mounted) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final isNew = (now - item.savedAt) < 2000;
      QuickSaveToastOverlay.show(context, item, isNew);
      // Trigger enrichment after new save
      if (isNew) _triggerEnrichment();
    }
  }

  String _canonicalizeUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return url.trim();
    return uri.toString();
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
      home: Scaffold(
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
    );
  }
}
