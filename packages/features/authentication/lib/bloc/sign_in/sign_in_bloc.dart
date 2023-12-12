import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repositorie/repositorie.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthenticationRepositoryImpl _authenticationRepository;

  //#region Initializers

  /// {@macro sign_in_bloc}
  SignInBloc({
    required AuthenticationRepositoryImpl authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(SignInState.initial()) {
    on<SignInEmailChangedEvent>(_handleSignInEmailChangedEvent);
    on<SignInPasswordChangedEvent>(_handleSignInPasswordChangedEvent);
    on<SignInSubmittedEvent>(_handleSignInSubmittedEvent);
  }

  //#endregion

  //#region Private methods

  _handleSignInEmailChangedEvent(
    SignInEmailChangedEvent event,
    Emitter<SignInState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  _handleSignInPasswordChangedEvent(
    SignInPasswordChangedEvent event,
    Emitter<SignInState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _handleSignInSubmittedEvent(
    SignInSubmittedEvent event,
    Emitter<SignInState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DataLoadStatus.loading));

      await _authenticationRepository.signInWithEmailAndPassword(
          state.email, state.password);

      emit(state.copyWith(status: DataLoadStatus.success));
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          errorReason: e.toString(),
          status: DataLoadStatus.failure,
        ),
      );
    }
  }

  //#endregion
}
