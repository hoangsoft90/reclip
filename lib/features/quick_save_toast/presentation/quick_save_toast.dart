import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/smart_save/presentation/smart_save_bottom_sheet.dart';

class QuickSaveToast extends StatefulWidget {
  final SavedItem? item;
  final AppDatabase db;
  final bool isNew;
  final VoidCallback? onView;
  final VoidCallback? onDismiss;

  const QuickSaveToast({
    super.key,
    this.item,
    required this.db,
    this.isNew = true,
    this.onView,
    this.onDismiss,
  });

  @override
  State<QuickSaveToast> createState() => _QuickSaveToastState();
}

class _QuickSaveToastState extends State<QuickSaveToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Auto-dismiss after toastDurationMs
    _dismissTimer = Timer(
      const Duration(milliseconds: AppStrings.toastDurationMs),
      _dismiss,
    );
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _showSmartSave() {
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (widget.item != null && context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => SmartSaveBottomSheet(item: widget.item!, db: widget.db),
        ).then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.isNew
        ? AppStrings.savedToast
        : AppStrings.alreadySavedToast;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isNew ? Colors.green.shade700 : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isNew ? Icons.check_circle : Icons.info_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _showSmartSave,
                child: Text(
                  AppStrings.addDetailsAction,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay manager for showing toast from anywhere
class QuickSaveToastOverlay {
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, SavedItem item, bool isNew, AppDatabase db) {
    // Remove existing toast if any
    _currentEntry?.remove();
    _currentEntry = null;

    // Try to get Overlay, skip if not available
    OverlayEntry? entry;
    try {
      entry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: QuickSaveToast(
            item: item,
            db: db,
            isNew: isNew,
            onDismiss: () {
              entry?.remove();
              _currentEntry = null;
            },
          ),
        ),
      );

      // This may throw if no Overlay is available
      Overlay.of(context).insert(entry);
      _currentEntry = entry;
    } catch (e) {
      // Overlay not available yet, silently skip
      entry?.remove();
    }
  }
}
