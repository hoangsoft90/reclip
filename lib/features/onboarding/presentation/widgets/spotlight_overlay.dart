import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reclip/features/onboarding/domain/onboarding_models.dart';

/// Full-screen overlay that highlights a target widget with a spotlight
/// cutout and shows a tooltip popup with guidance text.
///
/// The spotlight calculates the target's position from its GlobalKey,
/// creates a dimmed overlay with a transparent "hole" around the target,
/// and positions the tooltip in the optimal location.
///
/// Usage:
/// ```dart
/// SpotlightOverlay.show(
///   context: context,
///   step: onboardingStep,
///   onNext: () => manager.nextStep(),
///   onSkip: () => manager.skipFlow(),
/// );
/// ```
class SpotlightOverlay extends StatefulWidget {
  /// The onboarding step to display.
  final OnboardingStep step;

  /// Called when the user taps "Next" or "Done".
  final VoidCallback onNext;

  /// Called when the user taps "Skip".
  final VoidCallback? onSkip;

  /// Called when the user taps the backdrop (outside tooltip).
  final VoidCallback? onBackdropTap;

  /// Padding around the spotlight cutout.
  final double spotlightPadding;

  /// Border radius of the spotlight cutout.
  final double spotlightRadius;

  const SpotlightOverlay({
    super.key,
    required this.step,
    required this.onNext,
    this.onSkip,
    this.onBackdropTap,
    this.spotlightPadding = 8.0,
    this.spotlightRadius = 12.0,
  });

  /// Convenience method to show the overlay as a dialog.
  static Future<void> show({
    required BuildContext context,
    required OnboardingStep step,
    required VoidCallback onNext,
    VoidCallback? onSkip,
    VoidCallback? onBackdropTap,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Onboarding',
      barrierColor: Colors.transparent, // We draw our own dimming
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => SpotlightOverlay(
        step: step,
        onNext: onNext,
        onSkip: onSkip,
        onBackdropTap: onBackdropTap,
      ),
    );
  }

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Rect? _targetRect;
  _TooltipPlacement? _tooltipPlacement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Calculate positions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePositions();
      _controller.forward();
    });
  }

  void _calculatePositions() {
    final key = widget.step.targetKey;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    final padding = widget.spotlightPadding;
    _targetRect = Rect.fromLTWH(
      targetPosition.dx - padding,
      targetPosition.dy - padding,
      targetSize.width + padding * 2,
      targetSize.height + padding * 2,
    );

    // Calculate tooltip position
    final screenSize = MediaQuery.of(context).size;
    _tooltipPlacement = _calculateTooltipPlacement(
      targetRect: _targetRect!,
      targetPosition: targetPosition,
      targetSize: targetSize,
      screenSize: screenSize,
      preferred: widget.step.tooltipPosition,
    );
  }

  _TooltipPlacement _calculateTooltipPlacement({
    required Rect targetRect,
    required Offset targetPosition,
    required Size targetSize,
    required Size screenSize,
    required TooltipPosition preferred,
  }) {
    const tooltipHeight = 160.0;
    const tooltipWidth = 280.0;
    const margin = 16.0;

    if (preferred == TooltipPosition.auto || preferred == TooltipPosition.bottom) {
      // Try bottom first
      final top = targetRect.bottom + 8;
      if (top + tooltipHeight < screenSize.height - margin) {
        return _TooltipPlacement(
          top: top,
          left: _clampHorizontal(targetRect.center.dx - tooltipWidth / 2, tooltipWidth, screenSize.width, margin),
          position: TooltipPosition.bottom,
        );
      }
    }

    if (preferred == TooltipPosition.auto || preferred == TooltipPosition.top) {
      // Try top
      final bottom = targetRect.top - 8;
      if (bottom - tooltipHeight > margin) {
        return _TooltipPlacement(
          top: bottom - tooltipHeight,
          left: _clampHorizontal(targetRect.center.dx - tooltipWidth / 2, tooltipWidth, screenSize.width, margin),
          position: TooltipPosition.top,
        );
      }
    }

    if (preferred == TooltipPosition.auto || preferred == TooltipPosition.left) {
      // Try left
      final right = targetRect.left - 8;
      if (right - tooltipWidth > margin) {
        return _TooltipPlacement(
          top: _clampVertical(targetRect.center.dy - tooltipHeight / 2, tooltipHeight, screenSize.height, margin),
          left: right - tooltipWidth,
          position: TooltipPosition.left,
        );
      }
    }

    // Default: right or fallback to bottom
    final left = targetRect.right + 8;
    return _TooltipPlacement(
      top: _clampVertical(targetRect.center.dy - tooltipHeight / 2, tooltipHeight, screenSize.height, margin),
      left: left + tooltipWidth > screenSize.width - margin ? margin : left,
      position: TooltipPosition.right,
    );
  }

  double _clampHorizontal(double left, double width, double screenWidth, double margin) {
    if (left < margin) return margin;
    if (left + width > screenWidth - margin) return screenWidth - width - margin;
    return left;
  }

  double _clampVertical(double top, double height, double screenHeight, double margin) {
    if (top < margin) return margin;
    if (top + height > screenHeight - margin) return screenHeight - height - margin;
    return top;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null || _tooltipPlacement == null) {
      return const SizedBox.shrink();
    }

    final step = widget.step;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Stack(
            children: [
              // Dimmed background with spotlight cutout
              GestureDetector(
                onTap: widget.onBackdropTap ?? widget.onNext,
                child: CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _SpotlightPainter(
                    targetRect: _targetRect!,
                    radius: 12,
                  ),
                ),
              ),

              // Tooltip popup
              Positioned(
                top: _tooltipPlacement!.top,
                left: _tooltipPlacement!.left,
                child: _TooltipPopup(
                  step: step,
                  onNext: widget.onNext,
                  onSkip: widget.onSkip,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Paints a dimmed overlay with a transparent cutout around the target.
class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double radius;

  _SpotlightPainter({required this.targetRect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw full screen dimmed overlay
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Cut out the spotlight area
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(targetRect, Radius.circular(radius)),
      );

    final path = Path.combine(PathOperation.difference, fullPath, cutoutPath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tooltip popup with title, description, and action buttons.
class _TooltipPopup extends StatelessWidget {
  final OnboardingStep step;
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const _TooltipPopup({
    required this.step,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              step.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              step.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (step.skippable && onSkip != null)
                  TextButton(
                    onPressed: onSkip,
                    child: const Text('Skip'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal data class for tooltip positioning.
class _TooltipPlacement {
  final double top;
  final double left;
  final TooltipPosition position;

  const _TooltipPlacement({
    required this.top,
    required this.left,
    required this.position,
  });
}
