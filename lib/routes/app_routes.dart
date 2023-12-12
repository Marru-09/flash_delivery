import 'package:authentication/authentication.dart';
import 'package:flash_delivery/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show BuildContext, Container, Widget;
import 'routes.dart';

Map<String, Widget Function(BuildContext)> get appRoutes => {
      Routes.onboarding: (_) => const OnBoardingView(),
      Routes.signin: (_) => const SignInView(),
      Routes.signup: (_) => Container(
            child: const Center(
              child: Text('hola soy sign-up'),
            ),
          ),
      Routes.home: (_) => const MyHomeApp(),
    };
