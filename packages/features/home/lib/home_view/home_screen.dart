import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/bloc/home_bloc/home_bloc.dart';
import 'package:home/home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc(
        retrieveImpl: context.read(),
      )..add(const HomeRetrieveInformationEvent()),
      child: const Homeview(),
    );
  }
}
