import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reclip/features/onboarding/domain/onboarding_models.dart';
import 'package:reclip/features/onboarding/application/onboarding_manager.dart';
import 'package:reclip/features/onboarding/presentation/widgets/spotlight_overlay.dart';

/// Wraps a screen to manage onboarding flow display.
///
/// This widget:
/// 1. Initializes OnboardingManager from SharedPreferences
/// 2. Attempts to start the configured flow on first build
/// 3. Shows SpotlightOverlay for each step
/// 4. Manages step progression (Next/Skip/Done)
///
/// Usage:
/// ```dart
/// OnboardingScreenWrapper(
///   flowId: 'library_basics',
///   steps: [
///     OnboardingStep(
///       id: 'resurface',
///       targetKey: resurfaceKey,
///       title: '✨ Resurface',
///       description: 'Items you saved long ago appear here.',
///     ),
///     OnboardingStep(
///       id: 'search',
///       targetKey: searchKey,
///       title: 'Search',
///       description: 'Find anything you saved.',
///     ),
///   ],
///   child: LibraryScreen(db: db),
/// )
/// ```
class OnboardingScreenWrapper extends StatefulWidget {
  /// Unique flow identifier.
  final String flowId;

  /// Ordered list of onboarding steps for this screen.
  final List<OnboardingStep> steps;

  /// The actual screen content to display.
  final Widget child;

  /// Whether the flow can be skipped.
  final bool skippable;

  /// Whether to auto-start the flow on first build.
  final bool autoStart;

  const OnboardingScreenWrapper({
    super.key,
    required this.flowId,
    required this.steps,
    required this.child,
    this.skippable = true,
    this.autoStart = true,
  });

  @override
  State<OnboardingScreenWrapper> createState() =>
      _OnboardingScreenWrapperState();
}

class _OnboardingScreenWrapperState extends State<OnboardingScreenWrapper> {
  late OnboardingManager _manager;
  StreamSubscription<OnboardingState>? _subscription;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initManager();
  }

  Future<void> _initManager() async {
    final prefs = await SharedPreferences.getInstance();
    _manager = OnboardingManager(prefs);

    // Listen to state changes
    _subscription = _manager.stateStream.listen((state) {
      if (mounted) setState(() {});
    });

    // Auto-start flow if eligible
    if (widget.autoStart && mounted) {
      // Delay to let the screen render first (so GlobalKeys have context)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _manager.startFlow(OnboardingConfig(
            flowId: widget.flowId,
            steps: widget.steps,
            skippable: widget.skippable,
          ));
        }
      });
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _manager.dispose();
    super.dispose();
  }

  void _showSpotlight() {
    final state = _manager.state;
    if (!state.isActive || state.currentStep == null) return;

    SpotlightOverlay.show(
      context: context,
      step: state.currentStep!,
      onNext: () => _manager.nextStep(),
      onSkip: widget.skippable ? () => _manager.skipFlow() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show spotlight when state changes to active
    if (_manager.state.isActive && _manager.state.currentStep != null) {
      // Schedule spotlight show after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSpotlight();
      });
    }

    return widget.child;
  }
}
