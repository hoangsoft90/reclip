import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/network/http_client.dart';
import 'package:reclip/features/share_intent/share_intent_handler.dart';
import 'package:reclip/features/share_intent/quick_save_service.dart';
import 'package:reclip/features/metadata/metadata_adapter_factory.dart';
import 'package:reclip/features/metadata/application/enrichment_orchestrator.dart';
import 'package:reclip/features/metadata/application/thumbnail_download_service.dart';
import 'app.dart';

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
  runApp(
    const ProviderScope(
      child: ReclipApp(),
    ),
  );
}
