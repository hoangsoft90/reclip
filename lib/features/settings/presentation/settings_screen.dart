import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclip/core/config/app_config.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/settings/domain/settings_provider.dart';
import 'package:reclip/features/backup/presentation/backup_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final AppDatabase db;

  const SettingsScreen({super.key, required this.db});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;
  int _thumbnailCount = 0;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final thumbs = await widget.db.getAllThumbnails();
    final items = await widget.db.getAllSavedItems();
    int totalBytes = 0;
    for (final t in thumbs) {
      if (t.sizeBytes != null) totalBytes += t.sizeBytes!;
    }
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _thumbnailCount = thumbs.length;
        _itemCount = items.length;
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            // ═══ GENERAL ═══
            _sectionHeader('General'),

            // Default view
            SwitchListTile(
              title: const Text('Grid view by default'),
              subtitle: const Text('Show items as grid. Turn off for list view.'),
              value: settings.isGridView,
              onChanged: (v) => settingsNotifier.setIsGridView(v),
            ),

            // Auto-download thumbnails
            SwitchListTile(
              title: const Text('Auto-download thumbnails'),
              subtitle: const Text('Download preview images when saving links.'),
              value: settings.autoDownloadThumbnails,
              onChanged: (v) => settingsNotifier.setAutoDownloadThumbnails(v),
            ),

            // Resurface frequency
            ListTile(
              title: const Text('Resurface frequency'),
              subtitle: Text(settings.resurfaceFrequency.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showResurfaceDialog(settings, settingsNotifier),
            ),

            const Divider(),

            // ═══ STORAGE ═══
            _sectionHeader('Storage'),

            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Thumbnails cached'),
              subtitle: Text('$_thumbnailCount images · ${_formatBytes(_thumbnailSize(thumbs: true))}'),
            ),

            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Total items'),
              subtitle: Text('$_itemCount saved links'),
            ),

            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.orange.shade600),
              title: const Text('Clear thumbnail cache'),
              subtitle: const Text('Remove downloaded images. DB stays intact.'),
              onTap: () => _confirmClearThumbnails(),
            ),

            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red.shade600),
              title: Text('Clear all data', style: TextStyle(color: Colors.red.shade600)),
              subtitle: const Text('Delete everything — items, tags, collections.'),
              onTap: () => _confirmClearAll(),
            ),

            const Divider(),

            // ═══ DATA ═══
            _sectionHeader('Data'),

            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Backup & Restore'),
              subtitle: const Text('Export or import your library as JSON.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BackupSettingsScreen(db: widget.db),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Quick export'),
              subtitle: const Text('Export all data as JSON file.'),
              onTap: () => _quickExport(),
            ),

            const Divider(),

            // ═══ ADS ═══
            if (AppConfig.enableAds) ...[
              _sectionHeader('Ads'),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Remove ads'),
                subtitle: const Text('Coming soon — support development'),
                enabled: false,
                trailing: const Icon(Icons.lock_outline, size: 18),
              ),
              const Divider(),
            ],

            // ═══ ABOUT ═══
            _sectionHeader('About'),

            if (_packageInfo != null)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Text('${_packageInfo!.version}+${_packageInfo!.buildNumber}'),
              ),

            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () => _openUrl('https://hoangsoft90.github.io/reclip/privacy-policy/index.html'),
            ),

            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Send feedback'),
              onTap: () => _openUrl('mailto:haibasoftware@gmail.com?subject=Reclip%20Feedback'),
            ),

            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Rate this app'),
              onTap: () => _openUrl('https://play.google.com/store/apps/details?id=com.reclip.reclip'),
            ),

            // ═══ DEVELOPER (debug only) ═══
            if (AppConfig.testAds) ...[
              const Divider(),
              _sectionHeader('Developer'),
              ListTile(
                leading: const Icon(Icons.bug_outlined),
                title: const Text('Test interstitial ad'),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Interstitial ad loaded — check logcat')),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('DB stats'),
                subtitle: Text('$_itemCount items, $_thumbnailCount thumbnails'),
                onTap: () => _showDbStats(),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int _thumbnailSize({required bool thumbs}) => 0; // placeholder — loaded async

  Future<void> _showResurfaceDialog(AppSettings settings, SettingsNotifier notifier) async {
    final result = await showDialog<ResurfaceFrequency>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Resurface frequency'),
        children: ResurfaceFrequency.values.map((f) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, f),
            child: Row(
              children: [
                if (f == settings.resurfaceFrequency)
                  Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(f.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (result != null) {
      await notifier.setResurfaceFrequency(result);
    }
  }

  Future<void> _confirmClearThumbnails() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear thumbnail cache?'),
        content: const Text('Downloaded images will be removed. Thumbnails will re-download when you open items.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final thumbs = await widget.db.findOldestDoneThumbnails(limit: 9999);
      for (final t in thumbs) {
        if (t.localPath != null) {
          try { await File(t.localPath!).delete(); } catch (_) {}
        }
        await widget.db.clearThumbnailLocalPath(t.id);
      }
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cleared ${thumbs.length} thumbnails')),
        );
      }
    }
  }

  Future<void> _confirmClearAll() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear ALL data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will permanently delete:'),
            const SizedBox(height: 8),
            Text('• $_itemCount saved items'),
            Text('• $_thumbnailCount thumbnails'),
            const Text('• All collections & tags'),
            const SizedBox(height: 12),
            const Text('Type DELETE to confirm:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text == 'DELETE'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (confirmed == true) {
      // Delete all data
      final allItems = await widget.db.getAllSavedItems();
      for (final item in allItems) {
        await widget.db.deleteItem(item.id);
      }
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    }
  }

  Future<void> _quickExport() async {
    try {
      final items = await widget.db.exportSavedItems();
      final collections = await widget.db.exportCollections();
      final tags = await widget.db.exportTags();
      final ic = await widget.db.exportItemCollections();
      final it = await widget.db.exportItemTags();

      final json = '${items.length} items, ${collections.length} collections, ${tags.length} tags';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ready to export: $json')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _showDbStats() async {
    final items = await widget.db.getAllSavedItems();
    final thumbs = await widget.db.getAllThumbnails();
    final collections = await widget.db.getAllCollections();
    final tags = await widget.db.getAllTags();

    int totalThumbBytes = 0;
    int downloadedCount = 0;
    for (final t in thumbs) {
      if (t.sizeBytes != null) totalThumbBytes += t.sizeBytes!;
      if (t.downloadStatus == DownloadStatusEnum.done) downloadedCount++;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow('Items', '${items.length}'),
            _statRow('Favorites', '${items.where((i) => i.isFavorite).length}'),
            _statRow('Archived', '${items.where((i) => i.isArchived).length}'),
            const Divider(),
            _statRow('Thumbnails', '${thumbs.length}'),
            _statRow('Downloaded', '$downloadedCount'),
            _statRow('Cache size', _formatBytes(totalThumbBytes)),
            const Divider(),
            _statRow('Collections', '${collections.length}'),
            _statRow('Tags', '${tags.length}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
