import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:repositorie/repositorie.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RetrieveImpl _retrieveImpl;

  HomeBloc({
    required RetrieveImpl retrieveImpl,
  })  : _retrieveImpl = retrieveImpl,
        super(HomeState.initial()) {
    on<HomeRetrieveInformationEvent>(_handleHomeRetrieveInformationEvent);
  }

  Future<Position> determinePosition() async {
    LocationPermission locationPermission;
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    print(position.latitude);
    print(position.longitude);
  }

  Future<void> _handleHomeRetrieveInformationEvent(
    HomeRetrieveInformationEvent event,
    Emitter<HomeState> emit,
  ) async {
    getCurrentLocation();
    emit(state.copyWith(status: DataLoadStatus.loading));
    try {
      final data = await _retrieveImpl.retrieve();
      emit(state.copyWith(status: DataLoadStatus.success, data: data));
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(status: DataLoadStatus.failure),
      );
    }
  }
}
