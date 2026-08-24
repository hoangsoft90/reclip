import 'package:flutter/material.dart';

/// Wraps a child widget to show a helpful tooltip/modal when tapped
/// while in a disabled state.
///
/// When the user taps a disabled button, instead of doing nothing,
/// this widget shows a brief explanation of:
/// - Why the button is disabled
/// - What the user needs to do to unlock it
///
/// Usage:
/// ```dart
/// DisabledStateHelper(
///   disabled: items.isEmpty,
///   disabledReason: 'No items saved yet',
///   unlockHint: 'Share a link from any app to save it here.',
///   child: IconButton(
///     icon: Icon(Icons.search),
///     onPressed: items.isEmpty ? null : () => openSearch(),
///   ),
/// )
/// ```
class DisabledStateHelper extends StatefulWidget {
  /// Whether the wrapped widget is disabled.
  final bool disabled;

  /// Reason shown to the user explaining why it's disabled.
  final String disabledReason;

  /// Hint about how to unlock the feature.
  final String unlockHint;

  /// The child widget to wrap.
  final Widget child;

  /// Position of the tooltip relative to the child.
  final TooltipPosition tooltipPosition;

  /// How long the tooltip stays visible (auto-dismiss).
  final Duration displayDuration;

  const DisabledStateHelper({
    super.key,
    required this.disabled,
    required this.disabledReason,
    required this.unlockHint,
    required this.child,
    this.tooltipPosition = TooltipPosition.top,
    this.displayDuration = const Duration(seconds: 4),
  });

  @override
  State<DisabledStateHelper> createState() => _DisabledStateHelperState();
}

enum TooltipPosition { top, bottom, left, right }

class _DisabledStateHelperState extends State<DisabledStateHelper>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.disabled) return;
    _showTooltip();
  }

  void _showTooltip() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _DisabledTooltip(
        targetPosition: position,
        targetSize: size,
        reason: widget.disabledReason,
        hint: widget.unlockHint,
        position: widget.tooltipPosition,
        onDismiss: _removeOverlay,
        animation: _fadeAnimation,
      ),
    );

    overlay.insert(_overlayEntry!);
    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_controller.isAnimating) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}

/// The tooltip overlay widget shown when a disabled element is tapped.
class _DisabledTooltip extends StatelessWidget {
  final Offset targetPosition;
  final Size targetSize;
  final String reason;
  final String hint;
  final TooltipPosition position;
  final VoidCallback onDismiss;
  final Animation<double> animation;

  const _DisabledTooltip({
    required this.targetPosition,
    required this.targetSize,
    required this.reason,
    required this.hint,
    required this.position,
    required this.onDismiss,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const tooltipWidth = 260.0;
    const margin = 12.0;

    double top;
    double left;

    switch (position) {
      case TooltipPosition.top:
        top = targetPosition.dy - 120;
        left = _clamp(targetPosition.dx + targetSize.width / 2 - tooltipWidth / 2,
            tooltipWidth, screenSize.width, margin);
      case TooltipPosition.bottom:
        top = targetPosition.dy + targetSize.height + 8;
        left = _clamp(targetPosition.dx + targetSize.width / 2 - tooltipWidth / 2,
            tooltipWidth, screenSize.width, margin);
      case TooltipPosition.left:
        top = _clamp(targetPosition.dy + targetSize.height / 2 - 60, 120, screenSize.height, margin);
        left = targetPosition.dx - tooltipWidth - 12;
      case TooltipPosition.right:
        top = _clamp(targetPosition.dy + targetSize.height / 2 - 60, 120, screenSize.height, margin);
        left = targetPosition.dx + targetSize.width + 12;
    }

    return Stack(
      children: [
        // Dismiss on tap anywhere
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Tooltip
        Positioned(
          top: top,
          left: left,
          child: FadeTransition(
            opacity: animation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: tooltipWidth,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onInverseSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Hint
                    Text(
                      hint,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onInverseSurface
                            .withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _clamp(double value, double size, double max, double margin) {
    if (value < margin) return margin;
    if (value + size > max - margin) return max - size - margin;
    return value;
  }
}
