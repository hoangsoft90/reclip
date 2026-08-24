/// In-app Guidance & User Onboarding
///
/// Provides:
/// - [FeatureBadge] — "New" dot/label on icons
/// - [SpotlightOverlay] — highlight target, dim background, show tooltip
/// - [DisabledStateHelper] — explain why button is disabled
/// - [OnboardingManager] — step flow logic + SharedPreferences persistence
/// - [OnboardingScreenWrapper] — wraps screens to auto-show onboarding
library;

export 'domain/onboarding_models.dart';
export 'application/onboarding_manager.dart';
export 'presentation/widgets/feature_badge.dart';
export 'presentation/widgets/spotlight_overlay.dart';
export 'presentation/widgets/disabled_state_helper.dart';
export 'presentation/onboarding_screen_wrapper.dart';
