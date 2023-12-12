part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<Product> data;

  /// Current input status for the form.
  final DataLoadStatus status;

  @override
  List<Object?> get props => [
        data,
        status,
      ];

  const HomeState({
    required this.status,
    required this.data,
  });

  factory HomeState.initial() {
    return const HomeState(
      data: [],
      status: DataLoadStatus.initial,
    );
  }

  HomeState copyWith({
    List<Product>? data,
    DataLoadStatus? status,
  }) {
    return HomeState(
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  //#endregion
}
