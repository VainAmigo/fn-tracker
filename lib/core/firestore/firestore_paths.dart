import 'package:cloud_firestore/cloud_firestore.dart';

/// Централизованные пути к Firestore коллекциям пользователя.
/// Устраняет дублирование строковых путей по кодовой базе.
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String transactions = 'transactions';
  static const String categories = 'categories';
  static const String wallets = 'wallets';
  static const String goals = 'goals';
  static const String budget = 'budget';
  static const String scheduledPayments = 'scheduled_payments';
  static const String settings = 'settings';

  static CollectionReference<Map<String, dynamic>> userCollection(
    FirebaseFirestore firestore,
    String uid,
    String subCollection,
  ) =>
      firestore.collection(users).doc(uid).collection(subCollection);

  static CollectionReference<Map<String, dynamic>> transactionsRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      userCollection(firestore, uid, transactions);

  static CollectionReference<Map<String, dynamic>> categoriesRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      userCollection(firestore, uid, categories);

  static CollectionReference<Map<String, dynamic>> walletsRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      userCollection(firestore, uid, wallets);

  static CollectionReference<Map<String, dynamic>> goalsRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      userCollection(firestore, uid, goals);

  static CollectionReference<Map<String, dynamic>> budgetRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      userCollection(firestore, uid, budget);

  static CollectionReference<Map<String, dynamic>> budgetHistoryRef(
    FirebaseFirestore firestore,
    String uid,
    String budgetId,
  ) =>
      budgetRef(firestore, uid).doc(budgetId).collection('history');

  static CollectionReference<Map<String, dynamic>> scheduledPaymentsRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      userCollection(firestore, uid, scheduledPayments);

  static CollectionReference<Map<String, dynamic>> settingsRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      userCollection(firestore, uid, settings);
}
