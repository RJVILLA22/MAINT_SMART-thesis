import 'package:app/models/tool.dart';
import 'package:app/models/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '';

class ToolApi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> addTool(Tool tool) async {
    final docRef = _db.collection('tools').doc();
    tool.id = docRef.id;

    print(
      "API: Attempting to set document: ${docRef.id}",
    ); // Add this debug line

    try {
      // Use wait for the set operation with a strict timeout
      await _db
          .collection('tools')
          .doc(docRef.id)
          .set(tool.toJson())
          .timeout(const Duration(seconds: 5));

      print("API: Set successful");
      return docRef.id;
    } catch (e) {
      print("API ERROR: $e");
      rethrow; // Pass error back to Provider
    }
  }

  /// Get all tools (one-time fetch)
  Future<List<Tool>> getAllTools() async {
    final snapshot = await _db.collection('tools').get();
    return snapshot.docs.map((doc) => Tool.fromJson(doc.data())).toList();
  }

  /// Stream of all tools (real-time updates)
  Stream<List<Tool>> getToolsStream() {
    return _db
        .collection('tools')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Tool.fromJson(doc.data())).toList(),
        );
  }

  /// Update tool status (borrow or return)
  Future<void> updateToolStatus(
    String toolId,
    String status, {
    String? userId,
  }) async {
    final docRef = _db.collection('tools').doc(toolId);

    if (status == "borrowed") {
      await docRef.update({'status': 'borrowed', 'borrowedBy': userId});
    } else if (status == "available") {
      await docRef.update({'status': 'available', 'borrowedBy': null});
    }
  }

  /// Add a new ToolTransaction
  Future<String> addToolTransaction(ToolTransaction txn) async {
    final toolRef = _db.collection('tools').doc(txn.toolId);
    final toolSnap = await toolRef.get();

    if (!toolSnap.exists) {
      throw Exception("Tool not found.");
    }

    final tool = Tool.fromJson(toolSnap.data()!..['id'] = toolSnap.id);

    // Validation rules
    if (txn.action == "borrow") {
      if (tool.status == "borrowed") {
        throw Exception("Tool is already borrowed.");
      }
      // proceed with borrow
      final docRef = _db.collection('transactions').doc();
      txn.id = docRef.id;
      await docRef.set(txn.toJson());

      await updateToolStatus(txn.toolId, "borrowed", userId: txn.userId);

      return txn.toolId;
    } else if (txn.action == "return") {
      if (tool.status == "available") {
        throw Exception("Can't return an available tool.");
      }

      if (tool.borrowedBy != txn.userId) {
        throw Exception("You can only return tools you borrowed.");
      }
      // proceed with return
      final docRef = _db.collection('transactions').doc();
      txn.id = docRef.id;
      await docRef.set(txn.toJson());

      await updateToolStatus(txn.toolId, "available");

      return txn.toolId;
    }

    throw Exception("Invalid action: ${txn.action}");
  }

  /// Get all ToolTransactions (one-time fetch)
  Future<List<ToolTransaction>> getAllToolTransactions() async {
    final snapshot = await _db.collection('transactions').get();
    return snapshot.docs
        .map((doc) => ToolTransaction.fromJson(doc.data()))
        .toList();
  }

  /// Stream of all ToolTransactions (real-time updates)
  Stream<List<ToolTransaction>> getToolTransactionsStream() {
    return _db
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ToolTransaction.fromJson(doc.data()))
                  .toList(),
        );
  }

  Future<Tool?> getToolById(String toolId) async {
    try {
      final doc = await _db.collection('tools').doc(toolId).get();
      if (doc.exists && doc.data() != null) {
        return Tool.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null; // not found
    } catch (e) {
      throw Exception("Failed to fetch tool: $e");
    }
  }

  /// Update an existing tool's details
  /// This can update the model, description, borrow days, etc.
  Future<void> updateTool(String toolId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('tools')
          .doc(toolId)
          .update(data)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      throw Exception("Failed to update tool: $e");
    }
  }

  /// Delete a tool permanently from the inventory
  Future<void> deleteTool(String toolId) async {
    try {
      await _db
          .collection('tools')
          .doc(toolId)
          .delete()
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      throw Exception("Failed to delete tool: $e");
    }
  }
}
