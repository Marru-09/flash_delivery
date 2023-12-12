import 'package:domain/domain.dart';

abstract class SignUpRepository {
  Future<SignInResponse> register(SignUpData data);
}
