import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../datasources/local/local_message_dao.dart';
import '../datasources/remote/supabase_message_datasource.dart';

class PendingOperationSync {
  PendingOperationSync({
    required LocalMessageDao localDao,
    required SupabaseMessageDatasource messageDatasource,
    Connectivity? connectivity,
  })  : _localDao = localDao,
        _messageDatasource = messageDatasource,
        _connectivity = connectivity ?? Connectivity();

  final LocalMessageDao _localDao;
  final SupabaseMessageDatasource _messageDatasource;
  final Connectivity _connectivity;

  static const int _maxRetryCount = 10;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;

  void start() {
    _subscription ??= _connectivity.onConnectivityChanged.listen(
      (results) {
        final isOnline = !results.contains(ConnectivityResult.none);
        if (isOnline) unawaited(syncPending());
      },
    );
    unawaited(syncPending());
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final operations = await _localDao.getPendingOperations();
      for (final operation in operations) {
        await _trySync(operation);
      }
    } catch (_) {
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _trySync(Map<String, dynamic> operation) async {
    final id = operation['id'] as int;
    final retryCount = (operation['retry_count'] as num?)?.toInt() ?? 0;
    if (retryCount >= _maxRetryCount) return;

    final type = operation['operation_type'] as String? ?? '';
    try {
      switch (type) {
        case 'send_message':
          final payload =
              (operation['payload'] as Map<String, dynamic>?) ??
                  const <String, dynamic>{};
          final clientId = payload['client_id'] as String?;
          await _messageDatasource.insertMessage(
            Map<String, dynamic>.from(payload),
          );
          if (clientId != null && clientId.isNotEmpty) {
            await _localDao.deleteMessage(clientId);
          }
          break;
        default:
          break;
      }
      await _localDao.deletePendingOperation(id);
    } catch (_) {
      await _localDao.incrementRetryCount(id);
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}