import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tool.dart';
import '../models/transaction.dart';
import '../models/user.dart'; // AppUser

class InventoryApi {
  final _toolRef = FirebaseFirestore.instance.collection('tools');
  final _txnRef = FirebaseFirestore.instance.collection('transactions');
  final _userRef = FirebaseFirestore.instance.collection('users');

  /// 1. Stream of tools current user is borrowing
  Stream<List<Map<String, dynamic>>> streamUserBorrowedTools(String uid) {
    return _txnRef
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final Map<String, ToolTransaction> latestByTool = {};

          // 🔹 Get the latest transaction per tool for this user
          for (var doc in snap.docs) {
            final txn = ToolTransaction.fromJson({...doc.data(), 'id': doc.id});
            if (!latestByTool.containsKey(txn.toolId)) {
              latestByTool[txn.toolId!] = txn;
            }
          }

          List<Map<String, dynamic>> borrowed = [];

          for (var txn in latestByTool.values) {
            // ✅ Only count if the latest action is "borrow"
            if (txn.action != "borrow") continue;

            final toolDoc = await _toolRef.doc(txn.toolId).get();
            if (!toolDoc.exists) continue;

            final tool = Tool.fromJson({...toolDoc.data()!, 'id': toolDoc.id});
            final borrowedAt = txn.timestamp;
            final dueDate = borrowedAt.add(Duration(days: tool.borrowDays));

            borrowed.add({
              'model': tool.model,
              'borrowedAt': borrowedAt,
              'dueDate': dueDate,
            });
          }

          return borrowed;
        });
  }

  // 2. Stream of all borrowed tools
  /// Stream of all borrowed tools (works same as streamUserBorrowedTools)
  Stream<List<Map<String, dynamic>>> streamAllBorrowedTools() {
    return _txnRef.orderBy('timestamp', descending: true).snapshots().asyncMap((
      snap,
    ) async {
      print('📡 Received ${snap.docs.length} transaction docs');

      // Map of latest transaction per tool
      final Map<String, ToolTransaction> latestByTool = {};

      for (var doc in snap.docs) {
        ToolTransaction txn;
        try {
          txn = ToolTransaction.fromJson({...doc.data(), 'id': doc.id});
        } catch (e) {
          print('❌ Error parsing ToolTransaction: $e');
          continue;
        }

        // Keep only the first (latest) transaction per tool
        if (!latestByTool.containsKey(txn.toolId)) {
          latestByTool[txn.toolId!] = txn;
        }
      }

      List<Map<String, dynamic>> borrowed = [];

      for (var txn in latestByTool.values) {
        // ✅ Only include if the latest action is "borrow"
        if (txn.action != "borrow") continue;

        final toolDoc = await _toolRef.doc(txn.toolId).get();
        if (!toolDoc.exists) continue;

        final userDoc = await _userRef.doc(txn.userId).get();
        if (!userDoc.exists) continue;

        final tool = Tool.fromJson({...toolDoc.data()!, 'id': toolDoc.id});
        final user = AppUser.fromJson({...userDoc.data()!, 'id': userDoc.id});

        final borrowedAt = txn.timestamp;
        final dueDate = borrowedAt.add(Duration(days: tool.borrowDays));

        borrowed.add({
          'model': tool.model,
          'id': user.id,
          'borrowedBy': user.id_number ?? user.email,
          'borrowedAt': borrowedAt,
          'dueDate': dueDate,
        });
      }

      print('📋 Final borrowed list count: ${borrowed.length}');
      return borrowed;
    });
  }

  /// 3. Stream of available tools
  Stream<List<Map<String, dynamic>>> streamAvailableTools() {
    return _toolRef.where('status', isEqualTo: 'available').snapshots().map((
      snap,
    ) {
      return snap.docs.map((doc) {
        final tool = Tool.fromJson({...doc.data(), 'id': doc.id});
        return {
          'model': tool.model,
          'description': tool.description ?? "",
          'borrowDays': tool.borrowDays,
        };
      }).toList();
    });
  }

  /// 4. Stream of all tools
  Stream<List<Map<String, dynamic>>> streamAllTools() {
    return _toolRef.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final tool = Tool.fromJson({...doc.data(), 'id': doc.id});
        return {
          'model': tool.model,
          'description': tool.description ?? "",
          'borrowDays': tool.borrowDays,
          'status': tool.status,
          'id': tool.id,
        };
      }).toList();
    });
  }

  /// 5. Stream search (client-side filter)
  Stream<List<Map<String, dynamic>>> streamSearchTools(String keyword) {
    return _toolRef.snapshots().map((snap) {
      final lower = keyword.toLowerCase();
      return snap.docs
          .map((doc) {
            final tool = Tool.fromJson({...doc.data(), 'id': doc.id});
            return {
              'model': tool.model,
              'description': tool.description ?? "",
              'borrowDays': tool.borrowDays,
              'status': tool.status,
            };
          })
          .where(
            (tool) =>
                (tool['model'] as String).toLowerCase().contains(lower) ||
                (tool['description'] as String).toLowerCase().contains(lower),
          )
          .toList();
    });
  }
}
