import 'package:flutter/material.dart';
import '../database/database.dart';

// Re-export enums from database.dart to avoid duplicates
export '../database/database.dart'
    show PlatformEnum, ContentTypeEnum, MetadataStatusEnum, LinkStatusEnum, DownloadStatusEnum;

class PlatformInfo {
  final String displayName;
  final Color color;
  final IconData icon;

  const PlatformInfo({
    required this.displayName,
    required this.color,
    required this.icon,
  });

  static const Map<PlatformEnum, PlatformInfo> info = {
    PlatformEnum.reddit: PlatformInfo(
      displayName: 'Reddit',
      color: Color(0xFFFF4500),
      icon: Icons.forum,
    ),
    PlatformEnum.instagram: PlatformInfo(
      displayName: 'Instagram',
      color: Color(0xFFE4405F),
      icon: Icons.camera_alt,
    ),
    PlatformEnum.tiktok: PlatformInfo(
      displayName: 'TikTok',
      color: Color(0xFF000000),
      icon: Icons.music_note,
    ),
    PlatformEnum.youtube: PlatformInfo(
      displayName: 'YouTube',
      color: Color(0xFFFF0000),
      icon: Icons.play_circle_fill,
    ),
    PlatformEnum.x: PlatformInfo(
      displayName: 'X',
      color: Color(0xFF1DA1F2),
      icon: Icons.close,
    ),
    PlatformEnum.other: PlatformInfo(
      displayName: 'Web',
      color: Colors.grey,
      icon: Icons.language,
    ),
  };
}
