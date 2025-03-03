import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chit_model.dart';

class ChitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Get chits collection reference for a user
  CollectionReference _getChitsCollection(String userId) {
    return _firestore.collection('tracker').doc(userId).collection('chits');
  }

  // Add new chit
  Future<String> addChit(String userId, ChitModel chit) async {
    try {
      final String chitId = _uuid.v4();
      final chitWithId = chit.copyWith(id: chitId);

      await _getChitsCollection(userId).doc(chitId).set(chitWithId.toMap());

      return chitId;
    } catch (e) {
      print('Error adding chit: $e');
      rethrow;
    }
  }

  // Update chit
  Future<void> updateChit(String userId, ChitModel chit) async {
    try {
      await _getChitsCollection(userId).doc(chit.id).update(chit.toMap());
    } catch (e) {
      print('Error updating chit: $e');
      rethrow;
    }
  }

  // Delete chit
  Future<void> deleteChit(String chitId) async {
    try {
      // Get the chit first to get the userId
      final chitDoc = await _firestore.collectionGroup('chits').where('id', isEqualTo: chitId).get();

      if (chitDoc.docs.isEmpty) {
        throw Exception('Chit not found');
      }

      final userId = chitDoc.docs.first.get('userId') as String;
      await _getChitsCollection(userId).doc(chitId).delete();
    } catch (e) {
      print('Error deleting chit: $e');
      rethrow;
    }
  }

  // Get all chits for a user
  Stream<List<ChitModel>> getChits(String userId) {
    return _getChitsCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChitModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Get chits by status
  Stream<List<ChitModel>> getChitsByStatus(String userId, String status) {
    return _getChitsCollection(userId)
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChitModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Get chits by date range
  Stream<List<ChitModel>> getChitsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _getChitsCollection(userId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate), isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChitModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Get total amount for a specific month
  Future<double> getMonthlyTotal(String userId, DateTime month) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _getChitsCollection(userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate), isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0.0;
      for (var doc in querySnapshot.docs) {
        total += (doc.data() as Map<String, dynamic>)['amount'] as double;
      }
      return total;
    } catch (e) {
      print('Error getting monthly total: $e');
      rethrow;
    }
  }
}
