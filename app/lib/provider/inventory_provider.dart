// lib/provider/inventory_provider.dart
import 'dart:async';
import 'package:app/api/firebase_auth_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../api/inventory_api.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryApi _api = InventoryApi();
  final FirebaseAuthAPI _auth = FirebaseAuthAPI();
  String? get _uid => _auth.uid;

  // -------------------- Data --------------------
  List<Map<String, dynamic>> userBorrowed = [];
  List<Map<String, dynamic>> allBorrowed = [];
  List<Map<String, dynamic>> availableTools = [];
  List<Map<String, dynamic>> allTools = [];
  List<Map<String, dynamic>> searchResults = [];

  // -------------------- Loading flags --------------------
  bool isUserBorrowedLoading = false;
  bool isAllBorrowedLoading = false;
  bool isAvailableLoading = false;
  bool isAllToolsLoading = false;
  bool isSearchLoading = false;

  // -------------------- Errors --------------------
  String? userBorrowedError;
  String? allBorrowedError;
  String? availableError;
  String? allToolsError;
  String? searchError;

  // -------------------- Subscriptions --------------------
  StreamSubscription<List<Map<String, dynamic>>>? _userBorrowedSub;
  StreamSubscription<List<Map<String, dynamic>>>? _allBorrowedSub;
  StreamSubscription<List<Map<String, dynamic>>>? _availableSub;
  StreamSubscription<List<Map<String, dynamic>>>? _allToolsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _searchSub;

  InventoryProvider() {
    // eager listeners (if always needed)
    startAvailableListener();
    startAllToolsListener();
  }

  // ------------- user borrowed listener -------------
  void startUserBorrowedListener() {
    if (_uid == null) {
      userBorrowedError = "User not logged in";
      notifyListeners();
      return;
    }
    stopUserBorrowedListener();
    isUserBorrowedLoading = true;
    notifyListeners();

    _userBorrowedSub = _api
        .streamUserBorrowedTools(_uid!)
        .listen(
          (data) {
            userBorrowed = data;
            isUserBorrowedLoading = false;
            userBorrowedError = null;
            notifyListeners();
          },
          onError: (e) {
            isUserBorrowedLoading = false;
            userBorrowedError = e.toString();
            notifyListeners();
          },
        );
  }

  void stopUserBorrowedListener() {
    _userBorrowedSub?.cancel();
    _userBorrowedSub = null;
    isUserBorrowedLoading = false;
  }

  // ------------- all borrowed listener -------------
  void startAllBorrowedListener() {
    stopAllBorrowedListener();
    isAllBorrowedLoading = true;
    notifyListeners();

    _allBorrowedSub = _api.streamAllBorrowedTools().listen(
      (data) {
        allBorrowed = data;
        isAllBorrowedLoading = false;
        allBorrowedError = null;
        notifyListeners();
      },
      onError: (e) {
        isAllBorrowedLoading = false;
        allBorrowedError = e.toString();
        notifyListeners();
      },
    );
  }

  // lib/provider/inventory_provider.dart

  bool get hasOverdueTool {
    final now = DateTime.now();

    for (var tool in userBorrowed) {
      final dynamic borrowedAtRaw = tool['dueDate'];
      final int borrowDays = tool['borrowDays'] ?? 0;

      if (borrowedAtRaw != null) {
        DateTime borrowedDate;
        if (borrowedAtRaw is Timestamp) {
          borrowedDate = borrowedAtRaw.toDate();
        } else if (borrowedAtRaw is DateTime) {
          borrowedDate = borrowedAtRaw;
        } else {
          continue;
        }

        // Calculate the exact moment the tool becomes overdue
        final dueDate = borrowedDate;

        // DEBUG PRINTS
        print("Checking Tool: ${tool['model']}");
        print("Now: $now");
        print("Due: $dueDate");
        print("Is Now after Due? ${now.isAfter(dueDate)}");

        // Only return true if the current time has passed the due date
        if (now.isAfter(dueDate)) {
          return true;
        }
      }
    }
    return false;
  }

  void stopAllBorrowedListener() {
    _allBorrowedSub?.cancel();
    _allBorrowedSub = null;
    isAllBorrowedLoading = false;
  }

  // ------------- available tools listener -------------
  void startAvailableListener() {
    stopAvailableListener();
    isAvailableLoading = true;
    notifyListeners();

    _availableSub = _api.streamAvailableTools().listen(
      (data) {
        availableTools = data;
        isAvailableLoading = false;
        availableError = null;
        notifyListeners();
      },
      onError: (e) {
        isAvailableLoading = false;
        availableError = e.toString();
        notifyListeners();
      },
    );
  }

  void stopAvailableListener() {
    _availableSub?.cancel();
    _availableSub = null;
    isAvailableLoading = false;
  }

  // ------------- all tools listener -------------
  void startAllToolsListener() {
    stopAllToolsListener();
    isAllToolsLoading = true;
    notifyListeners();

    _allToolsSub = _api.streamAllTools().listen(
      (data) {
        allTools = data;
        isAllToolsLoading = false;
        allToolsError = null;
        notifyListeners();
      },
      onError: (e) {
        isAllToolsLoading = false;
        allToolsError = e.toString();
        notifyListeners();
      },
    );
  }

  void stopAllToolsListener() {
    _allToolsSub?.cancel();
    _allToolsSub = null;
    isAllToolsLoading = false;
  }

  // ------------- search tools listener -------------
  void startSearchListener(String keyword) {
    stopSearchListener();
    isSearchLoading = true;
    notifyListeners();

    _searchSub = _api
        .streamSearchTools(keyword)
        .listen(
          (data) {
            searchResults = data;
            isSearchLoading = false;
            searchError = null;
            notifyListeners();
          },
          onError: (e) {
            isSearchLoading = false;
            searchError = e.toString();
            notifyListeners();
          },
        );
  }

  void stopSearchListener() {
    _searchSub?.cancel();
    _searchSub = null;
    isSearchLoading = false;
    searchResults = [];
    notifyListeners();
  }

  // ------------- stop everything -------------
  void stopAllListeners() {
    stopUserBorrowedListener();
    stopAllBorrowedListener();
    stopAvailableListener();
    stopAllToolsListener();
    stopSearchListener();
  }

  @override
  void dispose() {
    stopAllListeners();
    super.dispose();
  }
}
