// lib/provider/transaction_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../api/tool_transaction_api.dart'; // assume you have streamUserRecentTransactions(uid)

class TransactionProvider with ChangeNotifier {
  final TransactionApi _api = TransactionApi();

  List<String> userRecent = [];
  String? error;

  StreamSubscription<List<String>>? _userTxnSub;

  void startUserRecentTransactions(String uid) {
    stopUserRecentTransactions();
    _userTxnSub = _api
        .streamUserRecentTransactions(uid)
        .listen(
          (data) {
            userRecent = data;
            error = null;
            notifyListeners();
          },
          onError: (e) {
            error = e.toString();
            notifyListeners();
          },
        );
  }

  void stopUserRecentTransactions() {
    _userTxnSub?.cancel();
    _userTxnSub = null;
    userRecent = [];
    notifyListeners();
  }

  @override
  void dispose() {
    stopUserRecentTransactions();
    super.dispose();
  }
}
