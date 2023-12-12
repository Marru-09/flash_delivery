import 'package:domain/domain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resource/resource.dart';

class SignUpRepositoryImpl implements SignUpRepository {
  final FirebaseAuth _auth;
  SignUpRepositoryImpl(this._auth);

  @override
  Future<SignInResponse> register(SignUpData data) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: data.email,
        password: data.password,
      );
      await userCredential.user!.updateDisplayName(
        "${data.name} ${data.lastname}",
      );

      return SignInResponse(null, userCredential.user);
    } on FirebaseAuthException catch (e) {
      return SignInResponse(
        parseStringToSignUpError(e.code),
        null,
      );
    }
  }
}
