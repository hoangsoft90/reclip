import 'package:flutter/material.dart';

/// A badge that overlays a "New" indicator on any child widget.
///
/// Usage:
/// ```dart
/// FeatureBadge(
///   show: !_onboardingManager.isFeatureSeen('backup'),
///   child: IconButton(icon: Icon(Icons.backup), onPressed: ...),
/// )
/// ```
///
/// Two variants:
/// - [BadgeVariant.dot] — small colored circle (default)
/// - [BadgeVariant.label] — "New" text chip
enum BadgeVariant { dot, label }

class FeatureBadge extends StatelessWidget {
  /// Whether to show the badge.
  final bool show;

  /// The widget to overlay the badge on.
  final Widget child;

  /// Badge style variant.
  final BadgeVariant variant;

  /// Badge position relative to the child.
  final Alignment alignment;

  const FeatureBadge({
    super.key,
    required this.show,
    required this.child,
    this.variant = BadgeVariant.dot,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: alignment.y < 0 ? -4 : null,
          bottom: alignment.y > 0 ? -4 : null,
          left: alignment.x < 0 ? -4 : null,
          right: alignment.x > 0 ? -4 : null,
          child: variant == BadgeVariant.dot
              ? _buildDot(context)
              : _buildLabel(context),
        ),
      ],
    );
  }

  Widget _buildDot(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'New',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
