import 'package:reclip/core/database/database.dart';

class MetadataResult {
  final MetadataStatusEnum status;
  final String? title;
  final String? description;
  final String? author;
  final String? authorUrl;
  final String? thumbnailUrl;
  final ContentTypeEnum? contentType;
  final String? failureReason;

  const MetadataResult({
    required this.status,
    this.title,
    this.description,
    this.author,
    this.authorUrl,
    this.thumbnailUrl,
    this.contentType,
    this.failureReason,
  });

  factory MetadataResult.failed(String reason) => MetadataResult(
        status: MetadataStatusEnum.failed,
        failureReason: reason,
      );
}
