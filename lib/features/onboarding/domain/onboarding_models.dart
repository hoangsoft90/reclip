import 'package:flutter/material.dart';

/// Represents a single onboarding step.
///
/// Each step targets a specific UI element and shows guidance text.
/// Steps are chained sequentially (Step 1 → Step 2 → ... → Finish).
class OnboardingStep {
  /// Unique identifier for this step (used for persistence).
  final String id;

  /// Global key of the target widget to highlight.
  /// The Spotlight overlay will calculate position from this key.
  final GlobalKey targetKey;

  /// Title shown in the tooltip popup.
  final String title;

  /// Description/body text shown in the tooltip.
  final String description;

  /// Position of the tooltip relative to the target widget.
  final TooltipPosition tooltipPosition;

  /// Whether this step can be skipped.
  final bool skippable;

  /// Optional condition that must be met before showing this step.
  /// If null, the step is always eligible.
  final bool Function()? condition;

  const OnboardingStep({
    required this.id,
    required this.targetKey,
    required this.title,
    required this.description,
    this.tooltipPosition = TooltipPosition.auto,
    this.skippable = true,
    this.condition,
  });
}

/// Tooltip placement relative to the target widget.
enum TooltipPosition {
  top,
  bottom,
  left,
  right,
  auto, // Automatically choose best position based on available space
}

/// Configuration for an onboarding flow (sequence of steps).
class OnboardingConfig {
  /// Unique flow identifier (e.g., 'first_save', 'library_basics').
  final String flowId;

  /// Ordered list of steps in this flow.
  final List<OnboardingStep> steps;

  /// Whether the entire flow can be skipped.
  final bool skippable;

  const OnboardingConfig({
    required this.flowId,
    required this.steps,
    this.skippable = true,
  });
}

/// State of the onboarding system.
class OnboardingState {
  /// Whether onboarding is currently active (showing a step).
  final bool isActive;

  /// Index of the current step in the flow.
  final int currentStepIndex;

  /// Total number of steps in the current flow.
  final int totalSteps;

  /// The current step being displayed.
  final OnboardingStep? currentStep;

  /// Whether this is the last step.
  final bool isLastStep;

  /// Whether this is the first step.
  final bool isFirstStep;

  const OnboardingState({
    required this.isActive,
    required this.currentStepIndex,
    required this.totalSteps,
    this.currentStep,
    required this.isLastStep,
    required this.isFirstStep,
  });

  /// Initial state (no onboarding active).
  factory OnboardingState.initial() => const OnboardingState(
        isActive: false,
        currentStepIndex: 0,
        totalSteps: 0,
        currentStep: null,
        isLastStep: true,
        isFirstStep: true,
      );

  /// Create a copy with updated fields.
  OnboardingState copyWith({
    bool? isActive,
    int? currentStepIndex,
    int? totalSteps,
    OnboardingStep? currentStep,
    bool? isLastStep,
    bool? isFirstStep,
  }) {
    return OnboardingState(
      isActive: isActive ?? this.isActive,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      currentStep: currentStep ?? this.currentStep,
      isLastStep: isLastStep ?? this.isLastStep,
      isFirstStep: isFirstStep ?? this.isFirstStep,
    );
  }
}
