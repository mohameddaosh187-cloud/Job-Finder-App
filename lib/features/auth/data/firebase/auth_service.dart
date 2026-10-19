import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_finder/features/auth/data/model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new account
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Account creation failed.');
    }

    await firebaseUser.updateDisplayName(fullName.trim());

    return UserModel(
      id: firebaseUser.uid,
      fullName: fullName.trim(),
      email: firebaseUser.email ?? email.trim(),
    );
  }

  // Sign in an existing account
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Login failed.');
    }

    return UserModel(
      id: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? email.trim(),
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Current signed-in user
  User? get currentUser => _auth.currentUser;

  // Authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
