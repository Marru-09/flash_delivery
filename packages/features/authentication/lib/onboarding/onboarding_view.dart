import 'package:authentication/sign_in/sign_in_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      body: const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Onboarding(),
              _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Onboarding extends StatelessWidget {
  //#region Initializers

  const _Onboarding({Key? key}) : super(key: key);

  //#endregion

  //#region Overriden methods

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Flexible(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.05),
            child: Container(
              height: 100,
              width: 100,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  //#endregion
}

class _Footer extends StatelessWidget {
  //#region Initializers

  const _Footer({Key? key}) : super(key: key);

  //#eendregion

  //#region Overriden methods

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoginButton(context),
          const SizedBox(height: 16),
          _buildRegisterButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //#endregion

  //#region Private methods

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      child: const Text('Sign In'),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SignInView(),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return OutlinedButton(
      child: const Text('Sign Up'),
      onPressed: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SignInView(),
          ),
        );
      },
    );
  }

  //#endregion
}
