import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/share_intent/share_intent_handler.dart';
import 'package:reclip/features/share_intent/quick_save_service.dart';
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
