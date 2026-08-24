import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reclip/features/onboarding/domain/onboarding_models.dart';

/// Manages onboarding flows: step progression, persistence, and trigger conditions.
///
/// Uses SharedPreferences to persist:
/// - `onboarding_completed_<flowId>`: whether a flow was completed
/// - `onboarding_step_<flowId>_<stepId>`: whether a specific step was seen
///
/// This ensures onboarding only shows once per user and respects skip actions.
class OnboardingManager {
  static const _prefixCompleted = 'onboarding_completed_';
  static const _prefixStep = 'onboarding_step_';
  static const _prefixFeature = 'feature_seen_';

  final SharedPreferences _prefs;

  /// Stream controller to notify UI of state changes.
  final _stateController = StreamController<OnboardingState>.broadcast();

  /// Current onboarding state.
  OnboardingState _state = OnboardingState.initial();

  /// Active flow being shown.
  OnboardingConfig? _activeFlow;

  OnboardingManager(this._prefs);

  /// Stream of onboarding state changes (for UI to listen).
  Stream<OnboardingState> get stateStream => _stateController.stream;

  /// Current state snapshot.
  OnboardingState get state => _state;

  /// Check if a specific flow has been completed.
  bool isFlowCompleted(String flowId) {
    return _prefs.getBool('$_prefixCompleted$flowId') ?? false;
  }

  /// Check if a specific step has been seen.
  bool isStepCompleted(String flowId, String stepId) {
    return _prefs.getBool('$_prefixStep$flowId$stepId') ?? false;
  }

  /// Check if a feature badge has been seen/dismissed.
  bool isFeatureSeen(String featureId) {
    return _prefs.getBool('$_prefixFeature$featureId') ?? false;
  }

  /// Mark a feature badge as seen.
  Future<void> markFeatureSeen(String featureId) async {
    await _prefs.setBool('$_prefixFeature$featureId', true);
  }

  /// Start an onboarding flow if eligible.
  ///
  /// Returns true if the flow started, false if already completed or
  /// conditions not met.
  Future<bool> startFlow(OnboardingConfig config) async {
    // Don't restart completed flows
    if (isFlowCompleted(config.flowId)) return false;

    // Filter steps by conditions
    final eligibleSteps = config.steps.where((step) {
      if (step.condition != null && !step.condition!()) return false;
      return true;
    }).toList();

    if (eligibleSteps.isEmpty) return false;

    _activeFlow = OnboardingConfig(
      flowId: config.flowId,
      steps: eligibleSteps,
      skippable: config.skippable,
    );

    _updateState(0);
    return true;
  }

  /// Move to the next step in the current flow.
  ///
  /// Marks the current step as completed in persistence.
  Future<void> nextStep() async {
    if (_activeFlow == null || _state.currentStep == null) return;

    // Mark current step as seen
    await _prefs.setBool(
      '$_prefixStep${_activeFlow!.flowId}${_state.currentStep!.id}',
      true,
    );

    final nextIndex = _state.currentStepIndex + 1;

    if (nextIndex >= _activeFlow!.steps.length) {
      // Flow complete
      await _completeFlow();
    } else {
      _updateState(nextIndex);
    }
  }

  /// Go to the previous step.
  Future<void> previousStep() async {
    if (_activeFlow == null || _state.currentStepIndex == 0) return;

    _updateState(_state.currentStepIndex - 1);
  }

  /// Skip the entire flow.
  Future<void> skipFlow() async {
    if (_activeFlow == null) return;

    // Mark all steps as seen (so they don't re-trigger individually)
    for (final step in _activeFlow!.steps) {
      await _prefs.setBool(
        '$_prefixStep${_activeFlow!.flowId}${step.id}',
        true,
      );
    }

    await _completeFlow();
  }

  /// Complete the current flow and persist.
  Future<void> _completeFlow() async {
    if (_activeFlow != null) {
      await _prefs.setBool(
        '$_prefixCompleted${_activeFlow!.flowId}',
        true,
      );
    }

    _activeFlow = null;
    _state = OnboardingState.initial();
    _stateController.add(_state);
  }

  /// Reset a flow (for testing or re-showing onboarding).
  Future<void> resetFlow(String flowId) async {
    await _prefs.remove('$_prefixCompleted$flowId');
  }

  /// Reset all onboarding state.
  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) =>
        k.startsWith(_prefixCompleted) ||
        k.startsWith(_prefixStep) ||
        k.startsWith(_prefixFeature));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    _activeFlow = null;
    _state = OnboardingState.initial();
    _stateController.add(_state);
  }

  void _updateState(int stepIndex) {
    if (_activeFlow == null) return;

    final step = _activeFlow!.steps[stepIndex];
    _state = OnboardingState(
      isActive: true,
      currentStepIndex: stepIndex,
      totalSteps: _activeFlow!.steps.length,
      currentStep: step,
      isLastStep: stepIndex == _activeFlow!.steps.length - 1,
      isFirstStep: stepIndex == 0,
    );
    _stateController.add(_state);
  }

  void dispose() {
    _stateController.close();
  }
}
