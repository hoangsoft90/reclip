import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';

/// Offline banner — shown at top of Library when device is offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.badgeOnlineToView,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
