import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String> userRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'user';
  }

  Future<void> signOut() => _auth.signOut();
}
