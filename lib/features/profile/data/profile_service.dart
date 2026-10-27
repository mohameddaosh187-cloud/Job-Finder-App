import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
final FirebaseAuth _auth = FirebaseAuth.instance;

User? get currentUser => _auth.currentUser;

String get userName {
final name = currentUser?.displayName?.trim();
if (name != null && name.isNotEmpty) {
  return name;
}
final email = currentUser?.email;

if (email != null && email.contains('@')) {
  return email.split('@').first;
}
return 'User';
}

String get userEmail => currentUser?.email ?? '';

String? get photoUrl => currentUser?.photoURL;

Future<void> updateName(String name) async {
final user = currentUser;
if (user == null) {
  throw Exception('No user is currently signed in.');
}

final trimmedName = name.trim();

if (trimmedName.isEmpty) {
  throw Exception('Name cannot be empty.');
}

await user.updateDisplayName(trimmedName);
await user.reload();
}

Future<void> signOut() async {
await _auth.signOut();
}
}
