# metrics-logger

## Purpose
Log metadata success rate theo từng platform vào local memory. Không dùng analytics SDK — chỉ in ra console để quan sát.

## Requirements

### REQ-1: Log event
Ghi event với timestamp vào list `_log` in-memory.

**Scenario: Log 1 event**
- Given: `MetricsLogger.logEvent('test_event', data: {'key': 'value'})`
- When: Gọi method
- Then: Entry `{event: 'test_event', timestamp: '...', key: 'value'}` được thêm vào `_log`, print `[Metrics] test_event {key: value}`
- Reference: `lib/features/metadata/application/metrics_logger.dart:7-13`

### REQ-2: Log metadata result
Ghi kết quả enrichment: platform + status.

**Scenario: Log success**
- Given: Enrichment thành công cho Reddit
- When: `MetricsLogger.logMetadataResult(PlatformEnum.reddit, MetadataStatusEnum.success)`
- Then: Event `{event: 'metadata_result', platform: 'reddit', status: 'success', timestamp: '...'}`
- Reference: `lib/features/metadata/application/metrics_logger.dart:15-19`

### REQ-3: Get platform stats
Tính số lượng success/partial/failed theo từng platform từ log.

**Scenario: Tính stats**
- Given: Log có 3 entries: Reddit success, Reddit failed, YouTube success
- When: `MetricsLogger.getPlatformStats()`
- Then: `{reddit: {success: 1, partial: 0, failed: 1}, youtube: {success: 1, partial: 0, failed: 0}}`
- Reference: `lib/features/metadata/application/metrics_logger.dart:22-33`

### REQ-4: Get all logs
Trả về bản copy không thay đổi được của toàn bộ log.

**Scenario: Read logs**
- Given: Đã log 5 events
- When: `MetricsLogger.allLogs`
- Then: Trả về `List<Map>` với 5 entries, `List.unmodifiable`
- Reference: `lib/features/metadata/application/metrics_logger.dart:21`

## Cần làm rõ
- `_log` là in-memory list — mất khi app restart. Ở Phase 2, metrics chỉ dùng để quan sát realtime, KHÔNG persist. Nếu muốn phân tích sau, cần ghi ra file hoặc SQLite table.
- `getPlatformStats()` chỉ đếm số lượng, KHÔNG tính percentage. Cần tự tính `(success / total) * 100` ở bên ngoài.
- `print()` statement trong production code — sẽ hiện trong logcat/release. Cần chuyển sang logging framework nếu muốn ẩn ở production.
