import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/item_detail/presentation/item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final AppDatabase db;

  const SearchScreen({super.key, required this.db});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<SavedItem> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    final results = await widget.db.searchSavedItems(query.trim());
    setState(() {
      _results = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _search('');
              },
            ),
        ],
      ),
      body: _hasSearched && _results.isEmpty
          ? const Center(
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return _buildSearchResult(item);
              },
            ),
    );
  }

  Widget _buildSearchResult(SavedItem item) {
    final platformInfo =
        PlatformInfo.info[item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final displayTitle = item.title ?? _extractDomain(item.canonicalUrl);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: platformInfo.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          platformInfo.icon,
          color: platformInfo.color,
          size: 20,
        ),
      ),
      title: Text(
        displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        platformInfo.displayName,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(item: item, db: widget.db),
          ),
        );
      },
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }
}
