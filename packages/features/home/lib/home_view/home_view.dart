import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/bloc/home_bloc/home_bloc.dart';
import 'package:home/widgets/card_product.dart';

class Homeview extends StatelessWidget {
  const Homeview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.only(top: 40, left: 15, bottom: 20),
            child: const Text(
              'Flash',
              style: TextStyle(
                  color: Color(0xFF761D1D),
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(top: 20, right: 15, bottom: 1),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC5E4),
                border: Border.all(
                  color: const Color(0xFFFFC5E4),
                  width: 1,
                  style: BorderStyle.solid,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(
                Icons.light,
                size: 20,
                color: Color(0xFFFFF705),
              ),
            ),
          ]),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          return previous.status != current.status;
        },
        builder: (context, state) {
          return state.status == DataLoadStatus.success
              ? _Body(info: state.data)
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List info;
  const _Body({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14, right: 11, left: 11),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: info.length,
              itemBuilder: (BuildContext context, int index) {
                return CardProduct(info[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
