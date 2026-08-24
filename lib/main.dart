import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/network/http_client.dart';
import 'package:reclip/features/share_intent/share_intent_handler.dart';
import 'package:reclip/features/share_intent/quick_save_service.dart';
import 'package:reclip/features/metadata/metadata_adapter_factory.dart';
import 'package:reclip/features/metadata/application/enrichment_orchestrator.dart';
import 'package:reclip/features/metadata/application/thumbnail_download_service.dart';
import 'package:reclip/features/onboarding/application/onboarding_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reclip/core/ads/ad_manager.dart';
import 'app.dart';

const _sentryDsn = 'https://2800d4f2840f11d317041a3d24a77194@o4505474077753344.ingest.us.sentry.io/4511963247083520';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// QuickSaveService provider
final quickSaveServiceProvider = Provider<QuickSaveService>((ref) {
  final db = ref.watch(databaseProvider);
  return QuickSaveService(db);
});

// MetadataAdapterFactory provider
final metadataAdapterFactoryProvider = Provider<MetadataAdapterFactory>((ref) {
  return MetadataAdapterFactory(HttpClient.instance);
});

// ThumbnailDownloadService provider
final thumbnailDownloadServiceProvider = Provider<ThumbnailDownloadService>((ref) {
  final db = ref.watch(databaseProvider);
  return ThumbnailDownloadService(db);
});

// EnrichmentOrchestrator provider
final enrichmentOrchestratorProvider = Provider<EnrichmentOrchestrator>((ref) {
  final db = ref.watch(databaseProvider);
  final factory = ref.watch(metadataAdapterFactoryProvider);
  final thumbnailService = ref.watch(thumbnailDownloadServiceProvider);
  return EnrichmentOrchestrator(db, factory, thumbnailService);
});

// AdManager provider
final adManagerProvider = Provider<AdManager>((ref) {
  final manager = AdManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

// OnboardingManager provider
final onboardingManagerProvider = FutureProvider<OnboardingManager>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final manager = OnboardingManager(prefs);
  ref.onDispose(() => manager.dispose());
  return manager;
});

// ShareIntentHandler provider
final shareIntentHandlerProvider = Provider<ShareIntentHandler>((ref) {
  final quickSaveService = ref.watch(quickSaveServiceProvider);
  final handler = ShareIntentHandler(quickSaveService);
  handler.init();
  ref.onDispose(() => handler.dispose());
  return handler;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await MobileAds.instance.initialize();

  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      // Use debug in development, error in production
      options.tracesSampleRate = 1.0;
      options.enableAutoSessionTracking = true;
    },
    appRunner: () => runZonedGuarded(() {
      // Global error handler — catch Flutter framework errors
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        // Send to Sentry
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
        debugPrint('[FlutterError] ${details.exceptionAsString()}');
      };

      runApp(
        const ProviderScope(
          child: ReclipApp(),
        ),
      );
    }, (error, stack) {
      // Catch async errors outside Flutter widget tree
      Sentry.captureException(error, stackTrace: stack);
      debugPrint('[ZoneError] $error');
      debugPrint('$stack');
    }),
  );
}
