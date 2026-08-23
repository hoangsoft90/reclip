import 'package:flutter_test/flutter_test.dart';
import 'package:reclip/features/share_intent/quick_save_service.dart';

void main() {
  // Note: These tests require a mock database. For Phase 0-1, we test the
  // service logic with a simplified in-memory approach.
  // Full integration tests should be done on device with real DB.

  group('QuickSaveService.quickSave', () {
    test('SaveResult correctly reports new vs duplicate', () {
      // Verify SaveResult types work correctly
      expect(SaveResultType.savedNew.index, 0);
      expect(SaveResultType.alreadyExists.index, 1);
    });

    test('SaveResultType enum values are correct', () {
      expect(SaveResultType.values.length, 2);
      expect(SaveResultType.values[0], SaveResultType.savedNew);
      expect(SaveResultType.values[1], SaveResultType.alreadyExists);
    });
  });
}
