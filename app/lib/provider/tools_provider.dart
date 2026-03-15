import 'dart:async';

import 'package:app/api/firebase_auth_api.dart';
import 'package:app/api/tool_api.dart';
import 'package:app/models/tool.dart';
import 'package:app/models/transaction.dart';
import 'package:flutter/material.dart';

class ToolsProvider extends ChangeNotifier {
  final ToolApi _api = ToolApi();

  final FirebaseAuthAPI _auth = FirebaseAuthAPI();
  String? get _uid => _auth.uid;

  List<Tool> _tools = [];
  List<Tool> get tools => _tools;

  List<ToolTransaction> _toolTransactions = [];
  List<ToolTransaction> get toolTransactions => _toolTransactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  Tool? _selectedTool;
  Tool? get selectedTool => _selectedTool;

  ToolsProvider() {
    listenToTools();
    listenToToolTransactions();
  }

  /// Listen to tools in real-time
  void listenToTools() {
    _api.getToolsStream().listen(
      (data) {
        _tools = data;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  /// Listen to ToolTransactions in real-time
  void listenToToolTransactions() {
    _api.getToolTransactionsStream().listen(
      (data) {
        _toolTransactions = data;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<String?> addTool(Tool tool) async {
    _setLoading(true);
    try {
      print("PROVIDER: Calling API...");
      final id = await _api.addTool(tool);
      print("PROVIDER: Received ID: $id");
      return id;
    } catch (e) {
      _error = e.toString();
      print('PROVIDER ERROR: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Borrow tool (creates ToolTransaction + updates tool)
  Future<String?> borrowTool(String toolId) async {
    _setLoading(true);
    try {
      final result = await _api.addToolTransaction(
        ToolTransaction(userId: _uid!, toolId: toolId, action: "borrow"),
      );
      return result; // ✅ return toolId if successful
    } catch (e) {
      _error = e.toString();
      return null; // ✅ return null on failure
    } finally {
      _setLoading(false);
    }
  }

  /// Return tool
  Future<String?> returnTool(String toolId) async {
    _setLoading(true);
    try {
      final result = await _api.addToolTransaction(
        ToolTransaction(userId: _uid!, toolId: toolId, action: "return"),
      );
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Tool?> getToolById(String toolId) async {
    _setLoading(true);
    try {
      final tool = await _api.getToolById(toolId);
      _selectedTool = tool;
      _error = null;
      return tool;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a tool
  Future<bool> deleteTool(String toolId) async {
    _setLoading(true);
    try {
      await _api.deleteTool(toolId); // Ensure your ToolApi has this method
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing tool
  Future<bool> updateTool(String toolId, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _api.updateTool(
        toolId,
        data,
      ); // Ensure your ToolApi has this method
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearSelectedTool() {
    _selectedTool = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
