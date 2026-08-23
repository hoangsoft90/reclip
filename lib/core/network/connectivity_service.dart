import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onlineStatusStream =>
      _connectivity.onConnectivityChanged.map((results) =>
          !results.contains(ConnectivityResult.none));

  Future<bool> get isOnline async =>
      !(await _connectivity.checkConnectivity()).contains(ConnectivityResult.none);
}
