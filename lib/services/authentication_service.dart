import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final _auth = FirebaseAuth.instance;
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print("KAYIT HATASI VAR: $e");
    }
  }

  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
