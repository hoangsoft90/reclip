import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted settings for the app.
class AppSettings {
  final bool isGridView;
  final bool autoDownloadThumbnails;
  final ResurfaceFrequency resurfaceFrequency;

  const AppSettings({
    this.isGridView = true,
    this.autoDownloadThumbnails = true,
    this.resurfaceFrequency = ResurfaceFrequency.weekly,
  });

  AppSettings copyWith({
    bool? isGridView,
    bool? autoDownloadThumbnails,
    ResurfaceFrequency? resurfaceFrequency,
  }) {
    return AppSettings(
      isGridView: isGridView ?? this.isGridView,
      autoDownloadThumbnails: autoDownloadThumbnails ?? this.autoDownloadThumbnails,
      resurfaceFrequency: resurfaceFrequency ?? this.resurfaceFrequency,
    );
  }
}

enum ResurfaceFrequency {
  never('Never', 0),
  daily('Daily', 1),
  weekly('Weekly', 7),
  monthly('Monthly', 30);

  final String label;
  final int intervalDays;
  const ResurfaceFrequency(this.label, this.intervalDays);
}

/// Notifier that reads/writes to SharedPreferences.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _load();
  }

  void _load() {
    state = AppSettings(
      isGridView: _prefs.getBool('settings_is_grid_view') ?? true,
      autoDownloadThumbnails: _prefs.getBool('settings_auto_download_thumbs') ?? true,
      resurfaceFrequency: ResurfaceFrequency.values.firstWhere(
        (e) => e.name == _prefs.getString('settings_resurface_freq'),
        orElse: () => ResurfaceFrequency.weekly,
      ),
    );
  }

  Future<void> setIsGridView(bool value) async {
    state = state.copyWith(isGridView: value);
    await _prefs.setBool('settings_is_grid_view', value);
  }

  Future<void> setAutoDownloadThumbnails(bool value) async {
    state = state.copyWith(autoDownloadThumbnails: value);
    await _prefs.setBool('settings_auto_download_thumbs', value);
  }

  Future<void> setResurfaceFrequency(ResurfaceFrequency value) async {
    state = state.copyWith(resurfaceFrequency: value);
    await _prefs.setString('settings_resurface_freq', value.name);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  throw UnimplementedError('Must be overridden in main with SharedPreferences');
});
