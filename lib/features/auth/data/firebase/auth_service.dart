import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_finder/features/auth/data/model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new account.
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedName = fullName.trim();
    final normalizedEmail = email.trim();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Account creation failed.');
    }

    await firebaseUser.updateDisplayName(normalizedName);
    await firebaseUser.reload();

    final updatedUser = _auth.currentUser;

    return UserModel(
      id: firebaseUser.uid,
      fullName: updatedUser?.displayName ?? normalizedName,
      email: updatedUser?.email ?? normalizedEmail,
    );
  }
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();

    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Login failed.');
    }

    return UserModel(
      id: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? normalizedEmail,
    );
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
