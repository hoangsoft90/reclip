class AppStrings {
  // Quick Save Toast
  static const savedToast = 'Saved to Library ✓';
  static const alreadySavedToast = 'Already saved';
  static const addDetailsAction = 'Add details';
  static const viewAction = 'View';
  static const toastDurationMs = 2000;

  // Item card badges
  static const badgeOnlineToView = '⚠ Online to view';
  static const badgeVideoUnavailableOffline = 'Video requires Internet';

  // Open Original
  static const openOriginalButton = 'Open Original';
  static const openOriginalFailedSnackbar =
      "Couldn't open the app or browser for this link.";

  // Fallback / metadata pending
  static const metadataPendingTitle = 'Fetching details…';
  static const metadataFailedTitle = 'Quick Link';
  static const metadataFailedSubtitle = "Couldn't load preview — tap to edit";

  // Smart Save bottom sheet
  static const smartSaveTitle = 'Add details';
  static const collectionLabel = 'Collection';
  static const tagsLabel = 'Tags';
  static const whySavedLabel = 'Why saving?';
  static const noteLabel = 'Note';
  static const saveButton = 'Save';
  static const cancelButton = 'Cancel';
  static const saveAsNewEntryButton = 'Save as new entry';

  static const whySavedOptions = <String, String>{
    'read_later': 'Read later',
    'try_this': 'Try this',
    'learn_this': 'Learn this',
    'inspiration': 'Inspiration',
    'just_interesting': 'Just interesting',
  };

  // Empty states
  static const libraryEmptyTitle = 'Nothing saved yet';
  static const libraryEmptySubtitle =
      'Share a post from any app to save it here.';

  // Library
  static const libraryTitle = 'Library';
  static const searchHint = 'Search library…';

  // Phase 2 - Quick Link Card
  static const editTitleAction = 'Edit title';
  static const quickLinkDomainPrefix = 'Saved from';

  // Phase 2 - Edit Title Dialog
  static const editTitleHint = 'Enter a title for this item';
  static const editTitleSave = 'Save';
  static const editTitleCancel = 'Cancel';

  // Phase 3 - Rediscovery
  static const resurfaceSectionTitle = '✨ Resurface';
  static const resurfaceEmptyState =
      'Save a few more things to see resurfaced items here.';

  // Phase 3 - Backup & Restore
  static const backupScreenTitle = 'Backup & Restore';
  static const exportBackupButton = 'Export backup now';
  static const restoreBackupButton = 'Restore from file';
  static const restoreMergeNotice =
      'Restoring merges data — nothing on this device will be deleted.';
  static const restoreSuccessMessage = 'Restored successfully';
  static const restoreChecksumError =
      'This backup file looks corrupted or was edited outside Reclip.';
}
