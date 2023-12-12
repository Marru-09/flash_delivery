import 'package:firebase_auth/firebase_auth.dart';
import 'package:repositorie/repositorie.dart';
import 'package:get/get.dart';
import 'package:resource/resource.dart';

Future<void> injectDependencies() async {
  Get.lazyPut<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(FirebaseAuth.instance),
  );
  Get.lazyPut<SignUpRepository>(
    () => SignUpRepositoryImpl(
      FirebaseAuth.instance,
    ),
  );
}
