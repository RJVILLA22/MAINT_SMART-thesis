import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import '../models/tool.dart';

class TransactionApi {
  final _txnRef = FirebaseFirestore.instance.collection('transactions');
  final _toolRef = FirebaseFirestore.instance.collection('tools');

  /// Stream of recent transactions for a user
  Stream<List<String>> streamUserRecentTransactions(String uid) {
    return _txnRef
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .asyncMap((snap) async {
          List<String> recent = [];

          for (var doc in snap.docs) {
            final txn = ToolTransaction.fromJson({...doc.data(), 'id': doc.id});

            // Fetch tool details
            final toolDoc = await _toolRef.doc(txn.toolId).get();
            if (!toolDoc.exists) continue;

            final tool = Tool.fromJson({...toolDoc.data()!, 'id': toolDoc.id});

            // Convert timestamp to DateTime
            final timestamp = txn.timestamp.toLocal();
            final timeAgo = _timeAgo(timestamp);

            // Sentence-case action (e.g., Borrow → Borrowed)
            final action = _pastTense(txn.action);

            // Example: "Borrowed Hammer 3 days ago"
            recent.add("$action ${tool.model} $timeAgo");
          }

          return recent;
        });
  }

  /// Convert a DateTime to a human-readable relative time
  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays >= 1) {
      return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago";
    } else {
      return "just now";
    }
  }

  /// Simple past tense converter for known actions
  String _pastTense(String action) {
    switch (action.toLowerCase()) {
      case 'borrow':
        return 'Borrowed';
      case 'return':
        return 'Returned';
      default:
        return '${action[0].toUpperCase()}${action.substring(1)}ed';
    }
  }
}
